## Blocking procedure assignment review


```
reg [7:0] byte = 8'b00001111;
...
// try to swap nibbles
byte[3:0] = byte[7:4];	// Byte is now 00000000
byte[7:4] = byte[3:0];
```


## Nonblocking procedure assignment review

```
reg [7:0] byte = 8'b00001111;
...
// try to swap nibbles
byte[3:0] <= byte[7:4];	// Byte is now 00001111
byte[7:4] <= byte[3:0]; // Byte is now 00001111

// Byte is 11110000 on the next delta cycle

//RHS expression value is calculated
//LHS var update is scheduled
```

[](img/eventQueue.png)

---

