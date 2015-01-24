#!/usr/bin/env python3
typesd={'int':'c_int','long int':'c_short', 'long':'c_short','size_t':'c_size_t', 
'void*':'type(c_ptr), value','void':None,
'char*':"CHARRR",'uint8_t*':'uint8_t*'
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

def camel(name):
  almostThere=''.join(n.capitalize() for n in name.split('_')).replace('*','')
  return almostThere[0].lower()+almostThere[1:]  

def listArgs(args):
  na=[arg.strip().split()[-1].replace('*','') for arg in args if arg != '']
  return ','.join(na)

def typeArgs(args):
  ans=''
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
    ans+='{0:s}, {1:s} :: {2:s}\n'.format(typ,intent,arg.replace('*',''))
  return ans

def processFunctions(functions):
  funcs={}
  for function in functions:
    name=function.split('(')[0].split()[-1].strip()
    typ=' '.join(function.split('(')[0].split()[1:-1]).replace('const ','')
    args=function.split('(')[1].replace(');','').split(',')
    if name[0]=='*':
      typ+='*'
    if typ.strip()=='void':
      tt='subroutine'
    else:
      tt='function'
    print(typ,name,args)
    fname=camel(name)
    if len(args)>1:
      print("{0:s} {1:s}({2:s})\n".format(tt,camel(name),listArgs(args)))
      print(typeArgs(args))
    else:
      print("{0:s} {1:s}()\n".format(tt,camel(name)))
    if typ != 'void':
      print("{0:s} :: {1:s}".format(typesd[typ],fname))

def createmodule():

  inh="/usr/include/zmq.h"
  lines=open(inh).read().replace("\\\n",'').split('\n')
  defines = [ line for line in lines if line.startswith('#define')] 
  functions = [ line for line in lines if line.startswith('ZMQ_EXPORT')] 
  cF=open('zmq_constants.F90','w')
  print(processDefines(defines),file=cF)
  cF.close()
  processFunctions(functions)

if __name__ == '__main__':
  createmodule()
