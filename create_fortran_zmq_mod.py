#!/usr/bin/env python3
import re

typesd={'int':'integer(c_int)','long int':'integer(c_long)',
'long':'integer(c_long)','size_t':'integer(c_size_t)', 
'void*':'type(c_ptr), value','void':None,
'char*':'character(kind=c_char), dimension(*)','uint8_t*':'uint8_t*'
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
  cons+="integer, parameter :: ZMQ_VERSION = 10000*ZMQ_VERSION_MAJOR + 100*ZMQ_VERSION_MINOR + ZMQ_VERSION_PATCH\n"  
  return cons

def listArgs(args):
  na=[arg.strip().split()[-1].replace('*','') for arg in args if arg != '']
  return ','.join(na)

def typeArgs(args):
  ans=''
  imp=[]
  na=[arg.strip().split()[-1] for arg in args if arg != '']
  tys=[' '.join(arg.strip().split()[0:-1]) for arg in args if arg != '']
  for ty,arg in zip(tys,na):
    if arg[0]=='*' or ty[-1]=='*':
      intent='intent(inout)'
    else:
      intent='intent(in   ), value'
    if arg[0]=='*' and ty=='void':
      ty+='*'
    if ty not in typesd.keys():
      typ=ty
    else:
      typ=typesd[ty]
    ans+='      {0:s}, {1:s} :: {2:s}\n'.format(typ,intent,arg.replace('*',''))
    h=getType(typ)
    if h is not None:
      imp.append(h)
  return ans,set(imp)

def processFunctions(functions,head):
  ans='module zmq\n'
  ans+=head
  ans+='\n  interface\n'
  for function in functions:
    ans+='\n!! {0:s}\n'.format(function) 
    name=function.split('(')[0].split()[-1].strip()
    typ=' '.join(function.split('(')[0].split()[1:-1]).replace('const ','')
    args=function.split('(')[1].replace(');','').split(',')
    if name[0]=='*':
      typ+='*'
    if typ.strip()=='void':
      tt='subroutine'
    else:
      tt='function'
    fname=name.replace('*','')
    if len(args)>1:
      ans+="    {0:s} {1:s}({2:s}) bind(c)\n".format(tt,fname,
           listArgs(args))
      arg,imp=typeArgs(args)
      z=getType(typesd[typ])
      if z is not None:
        ans+='      import {0:s}\n'.format(', '.join(imp|set([z])))
      else:
        ans+='      import {0:s}\n'.format(', '.join(imp))
      ans+=arg
    else:
      ans+="    {0:s} {1:s}() bind(c)\n".format(tt,fname)
      z=getType(typesd[typ])
      if z is not None:
        ans+='      import {0:s}\n'.format(z)
    if typ != 'void':
      ans+="      {0:s} :: {1:s}\n".format(typesd[typ],fname)
    ans+='    end {0:s} {1:s}\n'.format(tt,fname)
  ans+='  end interface\n'
  ans+='end module\n'
  return ans

def createmodule():
  inh="/usr/include/zmq.h"
  blob=open(inh).read().replace("\\\n",'')
  lines=blob.split('\n')
  defines = [ line for line in lines if line.startswith('#define')] 
  functions = [ line.replace('\n','') for line in re.findall(r'[\n]ZMQ_EXPORT .*? ; (?isx)', blob)] 
  cons='zmq_constants.F90'
  module='zmq.F08'
  cF=open(cons,'w')
  print(processDefines(defines),file=cF)
  cF.close()
  head="  use, intrinsinc :: iso_c_binding\n  implicit none\n  include '{0:s}'\n  public\n".format(cons)
  mF=open(module,'w')
  print(processFunctions(functions,head),file=mF)
  mF.close()
if __name__ == '__main__':
  createmodule()
