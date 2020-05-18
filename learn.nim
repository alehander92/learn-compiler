import os, strformat, strutils, sequtils, tables, macros, times
import "compiler/ast", "compiler/renderer", "compiler/idents", "compiler/lineinfos", "compiler/parser",  "compiler/ast", "compiler/options", "compiler/condsyms",  "compiler/extccomp", "compiler/pathutils", "compiler/renderer"
# import threadpool

type
  TypeEnv = ref object
    types*: Table[string, Type]

  Tree*[T] = ref object
    main*:   T
    elements*: Table[string, T]

  Ast* = ref object
    node*:  Node
    parent*: Ast
    children*: seq[Ast]
    path*: string

  ModuleTypeEnv* = ref object
    types*: Table[string, Type]
    used*: seq[Type]

#   Node* = object
    # a: string

  Node* = PNode

  Type* = object
    a: string

  Compiler* = ref object
    mainPath*: string
    env*: TypeEnv
    moduleAsts*: Tree[Ast]
    moduleTypeEnvs*: Tree[ModuleTypeEnv]

proc parseAst*(compiler: Compiler, source: string, path: string, parent: Ast): Ast =
  # var root = PNode(kind: nkStmtList)
  # var cache = newIdentCache()
  # echo path, " ", source.len
  # let lines = source.splitLines()
  # for i, line in lines:
  #   # echo path, " ", line
  #   if line.len > 0 and line.startsWith("import"):
  #     let name = line.split()[^1]
  #     root.sons.add(PNode(kind: nkImportStmt, sons: @[newIdentNode(cache.getIdent(name), TLineInfo())]))
  #   elif line.len > 0 and line.startsWith("proc"):
  #     let tokens = line.split()
  #     if tokens.len < 2:
  #       continue
  #     var name = tokens[1][0 .. ^2]
  #     root.sons.add(PNode(kind: nkProcDef, sons: @[newIdentNode(cache.getIdent(name), TLineInfo())]))
  #   else:
  #     root.sons.add(PNode(kind: nkDiscardStmt, sons: @[newIntNode(nkIntLit, 0)]))
  # var ast = Ast(parent: parent, path: path)
  # ast.node = root
  # # echo "root ", root
  # return ast

  var ast = Ast(parent: parent, path: path)
  var source = readFile(path)
  var conf = newConfigRef()
  var cache = newIdentCache()
  condsyms.initDefines(conf.symbols)
  conf.projectName = path
  conf.projectFull = AbsoluteFile(path)
  conf.projectPath = canonicalizePath(conf, AbsoluteFile(getCurrentDir())).AbsoluteDir
  conf.projectIsStdin = true
  # loadConfigs(DefaultConfig, cache, conf)
  extccomp.initVars(conf)
  var node = parseString(source, cache, conf)
  ast.node = node
  return ast

proc register*[T](tree: Tree[T], path: string, t: T, parent: T) =
  tree.elements[path] = t
  if parent.isNil:
    tree.main = t
  else:
    parent.children.add(t)

# proc loadImports*()
# proc loadImports*(compiler:)
macro p*(kind: untyped, code: untyped): untyped =
  result = quote:
    # echo "serial"
    `code`



proc loadImports(compiler: Compiler, ast: Ast): seq[string] =
  # echo "ast", ast.isNil
  for node in ast.node:
    if node.kind == nkImportStmt:
      # echo "node", node
      for module in node:
        result.add($module & ".nim")

macro openmp*(code: untyped): untyped =
  # 
  var emit = quote:
    {.emit: "#pragma omp parallel for num_threads(4)".}
    # {.emit: "for"

  result = nnkStmtList.newTree(emit, code)
  # echo result.repr
  
{.experimental: "parallel".}

var moduleTimes = initTable[string, Duration]()

# proc parse*(module: string) =
  # echo module
  # PNode()
  # example

proc parse*(compiler: Compiler, source: string, path: string, parent: Ast = nil) =
  # if not parent.isNil:
 
    # for i in 0 ..< 50000:
      # echo path
    # return

  var time = getTime()
  # echo time
 
  var ast = compiler.parseAst(source, path, parent)
  compiler.moduleAsts.register(path, ast, parent)
  var modules = compiler.loadImports(ast)
  echo modules
  # openmp:

  # parallel:
  for i in 0 || (modules.len - 1):
    setupForeignThreadGc()
  # for i in 0 .. modules.len - 1:
    try:
      let module = modules[i]
      compiler.parse(readFile(module), module, ast)
    except:
      echo getCurrentExceptionMsg()
    finally:
      discard
    # 
    # 
    # just no strings => interned


  var duration = getTime() - time
  moduleTimes[path] = duration
  #pragma omp parallel for num_threads(3)

proc merge*(compiler: Compiler) =
  for path, env in compiler.moduleTypeEnvs.elements:
    for name, t in env.types:
      if compiler.env.types.hasKey(name):
        echo "error " & name & " exists"
        quit(1)
      compiler.env.types[name] = t
  
  #for path, env in compiler.moduleTypeEnvs:
  #  for t in env.used:
  #    if not env.hasType(t):
  #      echo "error " & t.a & " not found"
  #      quit(1)

var mainPath = paramStr(1)
var main = readFile(mainPath)
var compiler = Compiler()
compiler.mainPath = mainPath
compiler.moduleAsts = Tree[Ast]()
compiler.env = TypeEnv()
compiler.moduleTypeEnvs = Tree[ModuleTypeEnv]()
var start = getTime()
compiler.parse(main, mainPath, nil)
var duration = getTime() - start
for path, moduleDuration in moduleTimes:
  echo path, " ",  $moduleDuration.inSeconds & "." & $(moduleDuration.inNanoseconds div 1_000_000)
echo $duration.inSeconds & "." & $(duration.inNanoseconds div 1_000_000)
compiler.merge()
# compiler.check()

echo "ok"

