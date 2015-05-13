# Initialization

    coffee ./server.coffee -n

Wait for the console to prompt some "Load took : XX ms" before moving to the next step.
It writes all its index to a file and loads it back. (Up to 3 minutes on my laptop)
Then access [http://localhost:3000/](http://localhost:3000/) to access the live version.

# Input

The input handles :
- `(...)` : Manage priorities
- `!` : Not
- `&&` : And
- `||` : Or
- `"..."` : Strict mode (Actually not so strict, only checks if the words have the same
  order in the files, not punctuation and stuff like that.

# Bonus 1

Meta-datas are sent over with the files on each request. The lookup uses only document ids,
but recontructs the document objects at the end of the request.

# Bonus 2

Once the generation-based system implemented, deleting a file is as easy as
setting its generation to `-1`.

# Bonus 3

Demonstration of handling in *strict* mode (`"..."`).

# Bonus 4

Not in the subject anymore, but handling of an AST as the input of our search function.

```
{
  foo: [1, 2],
  bar: [1, 3]
}

-- Doc2

doc | 1 | 2 | 3 |
gen | 1 | 2 | 1 |

foo[gen1] \doc{gen != 1}
U
foo[gen2] \doc{gen != 2}
```
