## Using Continuous and Procedural Assignment

Continuous Assignment Review 

- Only outside procedural block
- Continously drive nets
- Order of declaration does not affect the functionalities.

The simulator updates the continous assignments in any simulation cycle in which their inputs transition. 

```
wire [8:0] sum;
assign sum = a + b;		|can declare in either order
assign sum = c + d; 		|sum is result of a+b and c+d
```

For multiple continous assignment, the **wire**, **wand** and **wor** will resolve value conflict differently, as below

```
wire

|   | 0  | 1  | Z  | X  |
|---|----|----|----|----|
| 0 | 0  | X  | 0  | X  |
| 1 | X  | 1  | 1  | X  |
| Z | 0  | 1  | Z  | X  |
| X | X  | X  | X  | X  |

wand

|   | 0  | 1  | Z  | X  |
|---|----|----|----|----|
| 0 | 0  | 0  | 0  | 0  |
| 1 | 0  | 1  | 1  | X  |
| Z | 0  | 1  | Z  | X  |
| X | 0  | X  | X  | X  |

wor

|   | 0  | 1  | Z  | X  |
|---|----|----|----|----|
| 0 | 0  | 1  | 0  | X  |
| 1 | 1  | 1  | 1  | 1  |
| Z | 0  | 1  | Z  | X  |
| X | X  | 1  | X  | X  |

```
