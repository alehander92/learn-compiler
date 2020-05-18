
### learn-compiler


Praise God !

### what is this
learn-compiler is an effort in learning more for compilers and parallel programming.

design a language around limitations sometimes

what kind of features: easy to support

limited version of compile time code 

studiying how to implement elements like parsing, type checking, optimizations, code generation,
language service, repl, debug etc

studying how to do it with
  * parallel runs for modules
  * caching
  * modularity

for now a small language, which is maybe a subset of nim is used to target x86_64

plan is to also generalize it to

* my own language experiments
* other languages/subsets of languages
* other stuff

### build

```bash
nim cpp -d:useMalloc --boundchecks:off --exceptions:cpp --threads:on --tlsEmulation:off   --debugInfo --lineDir:on --nimcache:nimcache -d:release  --passC:"-fopenmp" --passL:"-fopenmp" learn.nim
```


