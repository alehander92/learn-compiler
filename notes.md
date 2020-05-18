string => Tree[Ast], Tree[ModuleTypeEnv] => Tree[Ast] => Tree[Ir]? => Tree[Raw] => binary

parallel:

file processing, sem checking, final generation

learn-compiler

cacheable:

lc build b.nim # b.build file/dir containing the precompiled type stuff and object files etc 

lc build a # import b

# b.build ready 
# a just reusing the type scheme and compiling there => finally linking together

b changes ? do we need to compile a again?
# we look for dependencies of b in a: if non changed (names: types/functions), dont

parallel:
a importing b1 to b8 => parallel 
lc-parse b1.nim # if cached, just return from that
lc-check-and-gen b1.lcast # b1.build 
link finally b1.o b2.o etc 

a:
  b1 b8
  b2
  b3
  b4
  b5
  b6
  b7
=> merge together, check for double defs / inexisting defs
=> continue
  b1 generating stuff etc

can we remove merge? maybe by doing it on checking? e.g. we assume its there 
=> minimal syscalls, especially short programs
=> do this in memory, no syscalls 
instead of lc-parse , just call a function on another core
all of them generate data structures in shared place
merge copy them if needed and then continue again like that

about ast => no allocations? allocate for all a fixed amount 
however 
  

for now 

just this: parallel parsing / checking in functions

# parallel parsing => 



parallel, caching, more about asm, x86_64, linking, languages, dsl-s etc

eventually if this works => dsl-ize or just add some more parametrism/dsls

