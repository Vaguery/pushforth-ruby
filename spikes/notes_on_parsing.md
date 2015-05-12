# notes on parsing and generating Pushforth

Each Pushforth script is a block

- syntactically valid code
  - `[]`
  - ``
  - `[{}]`
- syntactically invalid code
  - `]`
  - `{}`
  - `[[[]`
  - `[][]`
  - `[[],{]`