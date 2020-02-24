# Resume cartridge  

![Use landscape](Images/UseLandscape.gif)

ROM for executing memory and registers from specific situations.  
You can do things like state loading on real machines.  

## Assemble  

Assemble using nesasm.  

```shell
nesasm Main.asm
```

[build.bat](build.bat) is available for windows.  

## Cartridge  

Burn to NROM or MMC3 cartridge.  
Modify the [`Mapper` definition](Main.asm) as necessary to assemble it.  

## How to  

1. Start the cartridge that burned this program.  
2. Swap cartridges for the desired game without powering off.  
3. Press select button to start game.  

## User define  

Dump each memory from the emulator and change the [definition](StateDefine.asm).  
Game analysis is also required because it requires an address to restart the program, free memory, and a small amount of programming.  
As a sample, defined state to resume from strange map in SMB.  

This is running a temporary program transferred to RAM.  
It uses memory for the basic 25 bytes and the extra code to return to the game.  

## ToDo  

* None so far  

## Warning  

Removing and inserting the cassette while the power is on may damage the NES main unit.  
Use at your own risk.  

## License  

[MIT License](LICENSE).  
