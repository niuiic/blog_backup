---
title: Develop FPGA on Linux
date: 2021-06-15 10:46:55
tags:
  - Linux
  - FPGA
  - Systemverilog
  - verilator
categories:
  - [FPGA]
  - [Linux]
---

# 在 linux 下开发 FPGA

本文介绍如何在 linux 下开发 FPGA。

## 编译器

由于 FPGA 的特殊性，目前只有各商用 IDE 可以胜任整个开发流程。因此，也无需去找开源替代产品。直接使用开发板厂家提供的 IDE 是最合适的。如果该厂家并没有开发 IDE，可以使用 vivado 等较为常用的 IDE。

虽然使用 IDE，但是我们只用它来进行编译、下载。仿真与编辑建议使用其他工具进行。原因为目前没有任何 FPGA IDE 可以提供良好的编辑体验，另外像 vivado 这种 IDE 的仿真速度着实有点慢。

## 编辑器

在 linux 下建议使用 vim/neovim 或者 emacs 进行编辑。退一步可以选择 vscode。

关于 vim/neovim 对 systemverilog 的配置，见[另一篇文章](https://www.niuiic.top/2021/03/23/use-vim-as-the-editor-of-systemverilog/)。

## 仿真器

使用 gtkwave 作为波形查看器。

使用 verilog/VHDL 的用户可以选择 iverilog 作为仿真器。

iverilog 的仿真速度尚可，个人感觉比 vivado 快不少。关于 iverilog 搭配 gtkwave 的用法只要在网上稍微一搜就能找到，本文不赘述。

systemverilog 用户建议使用 verilator。原因有 iverilog 对 systemverilog 的支持还是不怎么样，另外 verilator 的速度要快的多，其自称是世界上最快的仿真器。

verilator 将 systemverilog 转化为 C++模型，利用多线程 C++进行仿真。因此它的速度很快，但也由于这个原理，用户需要用 C++编写测试文件。

> iverilog 和 verilator 是开源世界中最受欢迎的两个仿真器。虽然不太清楚其仿真结果是否会被承认，但其仿真通过的程序用商用仿真软件进行仿真几乎不会出问题。所以大不了最后用商用软件仿真一次出个结果。

下面来看一个案例。

```systemverilog
// Demo.sv

module Demo ();
  initial begin
    $display("Hello World");
    $finish;
  end
endmodule
```

上述代码并不会产生波形。下面编写对应的仿真测试文件。

```cpp
// sim_main.cpp

#include "VDemo.h"
#include <fstream>
#include <iostream>
#include <verilated.h>
#include <verilated_vcd_c.h>
using namespace std;

// top object pointer
VDemo *top = nullptr;
// wave generation pointer
VerilatedVcdC *tfp = nullptr;

// simulation timestamp
vluint64_t main_time = 0;
// upper limit of simulation timestamp
const vluint64_t sim_time = 1024;

int main(int argc, char **argv) {
  // init
  Verilated::commandArgs(argc, argv);
  Verilated::traceEverOn(true);
  top = new VDemo;
  tfp = new VerilatedVcdC;
  top->trace(tfp, 99);
  tfp->open("VDemo.vcd");

  while (!Verilated::gotFinish() && main_time < sim_time) {
    // simulation time step in
    top->eval();
    // wave output step in
    tfp->dump(main_time);
    main_time++;
  }

  // clear sources and exit
  tfp->close();
  delete top;
  delete tfp;
  exit(0);
  return 0;
}
```

上面的代码给出了一个标准的模板，语法非常简单，稍微有点 C++基础就可以编写。

下面针对该仿真测试做几点说明。

1. 仿真程序的头文件从哪里来

使用`verilator --cc Demo.sv --trace`可以生成一个`obj_dir`目录。该目录中包含由 systemverilog 转化而来的 cpp 文件。另外，在 verilator 的安装目录，通常在`/usr/share/verilator/include`下还有一系列通用的头文件。此外，就是 cpp 标准库的文件了。

2. 怎么使用该程序

执行命令`verilator --cc Demo.sv --trace --exe sim_main.cpp && make -j $(nproc) -C ./obj_dir -f VDemo.mk VDemo`。

`$(nproc)`表示计算机的最大线程数。比如 4 核 8 线程，则为 `-j 8`。该设置为程序编译时使用的线程数，建议设置为`$(nproc)`，可以减少，但最好不要增加。

以上命令将生成可执行文件，文件为`obj_dir/VDemo`。

运行该文件即可看到输出，如果仿真有波形，则会输出波形`obj_dir/VDemo.vcd`。然后使用`gtkwave obj_dir/VDemo.vcd`即可查看波形。

3. 如何配置信号

以上 systemverilog 代码并没有设置端口，也没有设置信号。现在假设有`input clk`，`output logic out`，并且`assign out = clk;`。

所有信号均可通过`top`指针访问，比如`top->clk`。下面，把`while`语句改成以下的内容。

```cpp
  while (!Verilated::gotFinish() && main_time < sim_time) {
    top->clk = top->clk == 0 ? 1 : 0;
    // simulation time step in
    top->eval();
    // wave output step in
    tfp->dump(main_time);
    main_time++;
  }
```

就可以模拟出 clk 信号。

## 优化仿真流程

仿真流程为整个开发流程的重中之重。下面介绍一些工具以提升仿真体验。

自制一个脚本来初始化项目。

```shell
sourcefile="demo.sv"
exe="Vdemo"
simfile="sim_main.cpp"
buildcmd="verilator --cc $sourcefile --trace"
runcmd="verilator --cc $sourcefile --trace --exe $simfile && make -j $(nproc) -C ./obj_dir -f $exe.mk $exe"

if [ $1 == "run" ]; then
    eval $runcmd &>/dev/null
    cd ./obj_dir
    eval "./$exe"
    if [ -f "$exe.vcd" ]; then
        gtkwave "./$exe.vcd"
    fi
elif [ $1 == "build" ]; then
    eval $runcmd
elif [ $1 == "check" ]; then
    eval $buildcmd
elif [ $1 == "clean" ]; then
    if [ -d "obj_dir" ]; then
        rm obj_dir
    fi
elif [ $1 == "watch" ]; then
    if [ -f "$exe.vcd" ]; then
        cd ./obj_dir
        gtkwave "./$exe.vcd"
    else
        echo -e "\033[31mNo vcd file exists.\033[0m"
    fi
elif [ $1 == "init" ]; then
    project_path=$(pwd)
    eval $buildcmd
    cat >compile_commands.json <<EOF
[
  {
    "directory": "$project_path",
    "command": "g++ $simfile -I ./obj_dir -I /usr/share/verilator/include -I /usr/share/verilator/include/*",
    "file": "./$simfile"
  }
]
EOF
    cat >$simfile <<EOF
#include "$exe.h"
#include <fstream>
#include <iostream>
#include <verilated.h>
#include <verilated_vcd_c.h>
using namespace std;

// top object pointer
$exe *top = nullptr;
// wave generation pointer
VerilatedVcdC *tfp = nullptr;

// simulation timestamp
vluint64_t main_time = 0;
// upper limit of simulation timestamp
const vluint64_t sim_time = 1024;

int main(int argc, char **argv) {
  // init
  Verilated::commandArgs(argc, argv);
  Verilated::traceEverOn(true);
  top = new $exe;
  tfp = new VerilatedVcdC;
  top->trace(tfp, 99);
  tfp->open("$exe.vcd");

  while (!Verilated::gotFinish() && main_time < sim_time) {
    // simulation time step in
    top->eval();
    // wave output step in
    tfp->dump(main_time);
    main_time++;
  }

  // clear sources and exit
  tfp->close();
  delete top;
  delete tfp;
  exit(0);
  return 0;
}
EOF
fi
```

注意查看`init`分支中`compile_commands.json`的内容里头文件的位置`/usr/...`是否正确。

使用时把`sourcefile`、`simfile`、`exe`修改一下即可。注意执行脚本的目录为`obj_dir`同目录。下面介绍各个部分的功能。

1. init：向当前目录放入仿真测试文件`sim_main.cpp`，以及 cpp lsp 需要的`compile_commands.json`（用于 cpp 代码检查、语法补全等）。
2. run：编译、运行，使用 gtkwave 打开波形图。
3. build：编译，检查源文件和仿真测试文件是否有错误。
4. check：检查源文件是否有错误。
5. clean：清理。
6. watch：查看波形图。

更进一步，使用 vim 的用户可以参考[另一片文章](https://www.niuiic.top/2021/04/17/vim-quickfix/)，将以上内容与 vim quickfix, asynctasks 结合，实现用快捷键完成整个仿真流程。

## 总结

根据以上内容，理清 linux 下开发 FPGA 的一种流程。

1. 使用 IDE 创建项目。
2. 使用外部编辑器编写代码。
3. 使用外部仿真器仿真。
4. 使用 IDE 完成剩下的工作。

优点

1. 编辑体验好。
2. 仿真速度快。
3. 由于 linux 底层原理，vivado 在 linux 上运行比在 windows 上快的多。如果还想进一步提升 vivado 的速度，可以使用多线程以及增量编译，这在网上都找得到。
