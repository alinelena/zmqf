#!/usr/bin/env python3

import sys, re

typesd = {
  'void'          : 'type(c_ptr)',
  'void*'         : 'type(c_ptr)',
                    
  'char'          : 'character(kind=c_signed_char)',
  'unsigned char' : 'character(kind=c_char)',
                    
  'short'         : 'integer(c_short)',
  'short int'     : 'integer(c_short)',
  'int'           : 'integer(c_int)',
  'long int'      : 'integer(c_long)',
  'long'          : 'integer(c_long)',                      
  'uint8_t'       : 'integer(c_int8_t)',
  'uint16_t'      : 'integer(c_int16_t)',
  'int32_t'       : 'integer(c_int32_t)',  
  
  'size_t'        : 'integer(c_size_t)', 
}

def breakLine(line):
  ll=0
  nl=''
  for w in line.split():
    ll+=len(w)
    if ll > 128 : 
      nl+=" & \n & "+w 
      ll=len(w)
    else:
      nl+=w
  return nl+"\n"

def getType(typ):
  a=None
  if typ != None:
    a=re.search('\((.*?)\)',typ)
  if a != None:
    return a.group(1).replace('kind=','')
  else:
    return None

def processDefines(defines):
  cons=''
  for define in defines:
    dd=define.split()
    if dd[1].startswith('__') or dd[1].startswith('ZMQ_MAKE_VERSION') or dd[1] == 'ZMQ_VERSION':
      continue
    rhs="integer, parameter :: {0:s} = ".format(dd[1])
    lh = [ d.replace('(','').replace(')','') for d in dd[2:] ]
    lhs=''.join(lh).split('|')
    if len(lhs)>1:
      c=''
      a=''
      for i in range(len(lhs)-1):
        c+=')'
        a+=" ior({0:s},".format(lhs[i])
      a+=lhs[-1]+c
      ll="{0:s} {1:s}\n".format(rhs,a)
      if len(ll)>130:
        cons+=breakLine(ll)
      else:
        cons+=ll
    else:
      cons+="{0:s} {1:s}\n".format(rhs,lhs[0])
  cons+="integer, parameter :: ZMQ_VERSION_K = 10000*ZMQ_VERSION_MAJOR + 100*ZMQ_VERSION_MINOR + ZMQ_VERSION_PATCH\n"  
  return cons

def listArgs(args):
  na=[arg.strip().split()[-1].replace('*','') for arg in args if arg != '']
  if na == ['void']: na = ''
  return ', '.join(na)

def typeArgs(args, funptrs):
  ans=''
  imp=[]
  h=None
  na=[arg.strip().split()[-1] for arg in args if arg != '']
  tys=[' '.join(arg.strip().split()[0:-1]) for arg in args if arg != '']
  hasSizeT= True if ','.join(tys).find(r'size_t')!=-1 else False
  for ty,arg in zip(tys,na):
    hasConst= True if ty.find(r'const')!=-1 else False
    if hasConst:
      ty=ty.replace('const ','')
    intent=''
    attr=''
    ### all the stars go to the type
    res=re.subn(r'\*','',arg)
    narg=res[0]

    if res[1] > 0:
      nty=ty+'*'*res[1]
    else:
      nty=ty

    if nty[-1]=='*':
      if hasConst:
        intent=', intent(in)'
      if hasSizeT or nty.startswith('char*'):
        ast=','.join(re.findall(r'\*',nty))
        attr=', dimension({0:s})'.format(ast)
     
    else:
      intent=', intent(in)'
      attr=', value'

    if nty == 'void*':
      attr=', value'

    nnty=nty.replace('*','')
    if nnty not in typesd.keys():
      #check if opaque:
      if nnty.startswith('struct'):
        typ='type({0:s})'.format('c_ptr')
        attr=''
      else:  
        typ='type({0:s})'.format(nnty)
    else:
      typ=typesd[nnty]
    if nnty in funptrs:
      typ='type({0:s})'.format('c_funptr')
      attr=', value'
      intent=''
 
    h=getType(typ)
    ans+='      {0:s}{1:s}{2:s} :: {3:s}\n'.format(typ,intent,attr,narg)
    if h is not None:
      imp.append(h)

  return ans,set(imp)

def processFunctions(blob,indent):
    
  funptrs = re.findall(r' \w+ \s* \((\w+)\) \s* \(.*?\) \s* ; (?isx)', blob)
  functions = [fun.replace('\n','') for fun in re.findall(r'[\n]ZMQ_EXPORT .*? ; (?isx)', blob)]
  funpatrs = re.compile(r'ZMQ_EXPORT \s* (.*?) \s* (\w+) \s* \( (.*?) \) \s* ; (?isx)')
  
  ans = '\n  interface\n'
  for function in functions:
    imp=set()
    ans+='\n!! {0:s}\n'.format(function) 
    typ, fname, args = funpatrs.findall(function)[0]
    typ = typ.replace('const','').replace(' *','*').strip()
    args = args.strip().split(',')
    
    ptrret = ('*' in typ) and (typ != 'void*')
    
    if typ == 'void':
      tt='subroutine'
    else:
      tt='function'    
    
    if ptrret:
        ffname = fname
        fname = fname + '_c'
    
    larg=listArgs(args)
    ans+=' '*indent*2 + "{0:s} {1:s}({2:s}) bind(c)\n".format(tt,fname,larg)
    if '*' in typ:
        ffun = ' '*indent*2 + "{0:s} {1:s}({2:s})\n".format(tt,ffname,larg)
    
    if larg != '':
      #print (fname,larg)
      arg,imp=typeArgs(args, funptrs)
    
    imps = imp
    z = 'c_ptr' if ptrret else getType(typesd[typ])
    imps = (imp|set([z])) if z is not None else imp
    
    ans+=' '*indent*3 + 'import {0:s}\n'.format(', '.join(imps))
    
    if larg != '':
      ans+=arg

    ftyp = 'type(c_ptr)' if ptrret else typesd[typ]
    if typ != 'void':
        ans+= ' '*indent*3 + "{0:s} :: {1:s}\n".format(ftyp,fname)  
    ans+=' '*indent*2 + 'end {0:s} {1:s}\n'.format(tt,fname)
  ans+=' '*indent*1 + 'end interface\n'
  
  return ans


def figure_types(l):
    tmp = re.sub(r'[*]\s+(?ixs)','*',l.replace('*', ' *').strip('; ')).split(',')
    names = [tmp[0].split()[-1]] + tmp[1:]
    size_ptr = re.compile(r' \[.*?\] (?ixs)')
    
    ctype = ' '.join(tmp[0].split()[:-1])
    ftype = typesd[ctype] if ctype in typesd else ('*to be def* ' + ctype)
    s = ''
    for i,name in enumerate(names):
        name = name.strip()
        bare = size_ptr.sub('',name).strip()
        #all this is to legalise illegal in f90 variable names like '_'.
        if bare.startswith('_'): bare = 'cfvar%i'%i + bare
        if bare.endswith('_'): bare = bare + 'cfvar%i'%i
        mo = size_ptr.search(name)
        size = ''
        if mo != None: size = mo.group(0)
        names[i] = bare + size.replace('[','(').replace(']',')')
        s += '\n'
        s += ftype if not names[i].startswith('*') else 'type(c_ptr)'
        s += ' :: '
        s += names[i].lstrip('*')
    
    return s.lstrip('\n')

def processStructs(s, indent):
    
    struct_spt = re.compile(r'struct \s* \w* \s* { \s* (.*?) \s* } \s* (\w+) \s*; (?isx)')
    structs = struct_spt.findall(s)
    
    fstructs = []
    for st in structs:
        ft = []
        body, name = st
        #print (name, body)
        ft.append('type, bind(c) :: ' + name)
        
        for l in body.splitlines():
            if l.strip().startswith('#'):
                ft.append(l)
            else:
                ft.append(' '*indent + figure_types(l).replace('\n','\n'+' '*indent))
        ft.append('end type ' + name)
        
        fstructs.append('\n'.join(ft))
    
    return '\n\n'.join(fstructs)


def clean(s):
    s = s.replace("\\\n",'').strip()  
    s = re.sub(r'// .*         (?ixm)',  '', s) # delete inline comments
    s = re.sub(r'/[*] .*? [*]/ (?ixs)',  '', s) # delete multiline comments
    s = re.sub(r'\s+ ;          (?ix)', ';', s) # bring endline forward
    s = re.sub(r'\s+ \[         (?ix)', '[', s) # bring [ forward
    
    i = 0
    n = 1
    while (n > 0):
        s, n = re.subn(r'[*] \s* ,      (?ix)', '*s%i,'%i, s, count = 1) # put dummy args for *
        i += 1
    
    return s



def createmodule():
  if len(sys.argv)==2:
    inh=sys.argv[1]
  else:
    inh='/usr/include/zmq.h'
    print("No path passed default will be used")
  print("process {0:s}".format(inh))
  blob = clean(open(inh).read())
  lines=blob.split('\n')
  defines = [ line for line in lines if line.startswith('#define')] 
   
  cons='zmq_constants.F90'
  module='zmq.F90'
  cF=open(cons,'w')
  print(processDefines(defines),file=cF)
  cF.close()
  
  indent = 2
  
  head = "module zmq\n  use, intrinsic :: iso_c_binding\n  implicit none\n  include '{0:s}'\n  public\n\n".format(cons)  
  
  # the function indents only within its own level
  head += ' '*indent + processStructs(blob, indent).replace('\n', '\n'+' '*indent)
  head += '\n' + processFunctions(blob, indent)
  head += 'end module\n'
  
  #do not indent preprocessing
  head = re.sub(r'^ \s* [#] (?isxm)', '#', head)

  mF=open(module,'w')
  print(head, file=mF)
  mF.close()

if __name__ == '__main__':
  createmodule()
