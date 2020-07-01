# frankenjiffytest
Quick test program to test rogue jiffy kernals with cc65 disk i/o routines.

ScottFree64 had some bug reports that the system would fail while loading the dat files. It was later revealed that the culprit was a [rogue jiffydos patch](https://csdb.dk/release/?id=137938). The symptoms seems to be inconsistant reads, it will skip over values being read with the fscanf routine.   

I'm providing this test program to allow someone to fix their franken jiffy dos patches if they want their stuff to work with cc65 executables.  Currently the one jiffydos patch known to cause an issue fails usually before it gets to the 11th line of numbers.

When running this you need a kernal rom (whatever jiffydos you run) and a jiffydos drive rom as well. I've tested this with the patched jiffydos, and a genuine jiffydos drive rom and was able to reproduce this issue.  

To build (with cc65!):  
`make`

To run:  
Use the d64:
```
load"*",8,1
run
```
or  
```
run:rem sometestfile
```

The test file is just simply:
```
[some value that is the count of subsequent lines to read]

[seven  number values separated by spaces][an eigth number that is the sum of the first seven]
```
ex:
```
2

900 0 0 0 0 0 9900 10800
1507 0 0 0 0 0 9900 11407
```
