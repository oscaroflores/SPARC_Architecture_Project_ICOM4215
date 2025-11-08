# Build and Compile on OSX
Download and install `Verilator` library using homebrew.
```
brew install verilator
```
(optional) Install GTKWave
```
brew install --HEAD randomplum/gtkwave/gtkwave
```
Now to compile your verilog module and testbench use:
```
verilator --binary yourModule.v
```
`--binary` tells verilator to create a binary that you can run for the simulation. The default location is `./obj_dir/V<yourModule>`.
Now to run the verilog simulation:
```
./obj_dir/V<yourModule>
```
If you plan on using GTKWave for signal visualization simply add the `--trace` flag to the shell command running `--binary`. Also, add the following code to your top verilog module:
```
initial 
      begin
         $dumpfile("dump.vcd");
         $dumpvars();
      end

    // When you end your simulation ($finish) you should flush ($dumpflush)

    initial
    begin
        #1000 $dumpflush;
        $finish;
    end
```
After running simulation, run GTKWave:
```
gtkwave dump.vcd
```
## Verilator flags to keep at hand:
--binary                    Build model binary
--trace                     Enable VCD waveform creation
--top <topname>             Alias of --top-module
--top-module <topname>      Name of top-level input module

# Running the PPU_ControlPath testbench (Windows + Icarus Verilog)

1. Open Command Prompt or PowerShell.
2. Navigate to the source folder for this phase:
```
cd fase_2
cd src
```
3. Compile all Verilog source files (including the testbench):
```
iverilog -o PPU_ControlPath_tb.vvp *.v
```
4. Run the generated simulation:
```
vvp PPU_ControlPath_tb.vvp
```
5. (Optional) If a VCD file (PPU_ControlPath_tb.vcd) is produced and you have GTKWave installed, view waveforms:
```
gtkwave PPU_ControlPath_tb.vcd
```

Shortcut (single line):
```
cd fase_2\src && iverilog -o PPU_ControlPath_tb.vvp *.v && vvp PPU_ControlPath_tb.vvp
```

Notes:
- Ensure the testbench file is in the same src directory so the wildcard (*.v) picks it up.
- Add or remove source files as the design grows; wildcard recompiles everything each time.
