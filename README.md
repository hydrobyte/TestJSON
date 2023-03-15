# Test JSON Libraries
A simple project to test JSON libraries with Delphi and C++Builder.

![](./images/Github-01-A.png)


## Disclaimer
This is a *simple* project and not a final product. I know that there are many points that could be better structured. The initial goal was to quickly deploy a single unit "FoMain" kind of project, spending time to include and test the most popular JSON libraries for `Delphi`. Yes, the initial commit has just `C++Builder` code. The `Delphi` version is on my schedule. Also, the tests here have dimensions that don't represent the most common cases of data manipulation in JSON. Finally, the analysis of the results is not intended to detract from any of the tested libraries and should not be seen as any kind of criticism of the authors of the libraries. Knowledge is freedom.


## Libraries
- [McJSON](https://github.com/hydrobyte/McJSON)
- [uLkJSON](https://sourceforge.net/projects/lkjson/)
- [System.JSON](https://docwiki.embarcadero.com/Libraries/Sydney/en/System.JSON.TJSONObject)
- [JsonDataObjects](https://github.com/ahausladen/JsonDataObjects)
- [SuperObject](https://github.com/hgourvest/superobject)
- [JsonTools](https://github.com/sysrpl/JsonTools)
- [Json4Delphi](https://github.com/MaiconSoft/json4delphi)


## Compiler and Computer
- C++Builder VCL project built with version 10.2 (Tokyo).
- Old 64 bits machine: AMD A12-9700P RADEON R7, 10 COMPUTE CORES 4C+6G - 2.50 GHz - 16 GB RAM.


## Tests
There are three test types:
- Speed Run
  - Generate `N` items `{ ... "key_i":"value_i", ... }`
  - Save to file
  - Clear
  - Load from file
  - Find `M` items
  - Clone/parse
- Validation
- Open File


## Procedure
For each library and test type the app was ran and closed. 
The results of `Speed Run` compute the average time of 5 repetitions.
The Memory consuption is logged and will be part of some results.


## Speed Run test
This is a performance test for libraries with the following configuration (select `Default` in the `Preset` list).
- `N` = 50k items.
- `M` = 1k items (keep same random sequence for all tests).
- 5 repetitions.
- Memory consuption after the `Genereate` sub-test.
- It is expected that the `Clone/Parse` sub-test consumes twice as memory as the `Generate` or `Load from file` sub-test.
- See [.\images\Github-02*.png](.\images) images as confirmation.

Library          | Generate  | Save     | Load     | Find     | Parse   | Total      | Memory   |
:----------------|----------:|---------:|---------:|---------:|--------:|-----------:|---------:|
`McJSON`         |     .09 s |    .08 s |    .04 s |    .39 s |   .10 s |     0.74 s | 5.09 MiB |  
`LkJson`         |     .19 s |    .08 s |    .16 s |    .01 s |   .23 s |     0.74 s | 2.88 MiB |
`System.JSON`    |     .12 s |    .08 s |    .24 s |   2.94 s |   .32 s |     3.78 s | 9.39 MiB |
`JsonDataObjects`|   15.23 s |    .02 s |    .17 s |    .30 s |   .19 s |    15.97 s | 4.30 MiB |
`JsonTools`      |   24.41 s |        - |        - |    .46 s | 23.50 s |    48.39 s | 5.78 MiB |
`Json4Delphi`    |     .10 s |    .11 s |  63.94 s |    .93 s | 64.03 s |   129.17 s | 6.81 MiB |

Notes: 
 - See [Know issues](#know-issues) about the incomplete test for `JsonTools`.


## Scaling test
Here are some results just for the `Generate` sub-test increasing `N`.

Library          | 1k        | 5k       | 10k      | 25k      | 50k     |
:----------------|----------:|---------:|---------:|---------:|--------:|
`McJSON`         |     .01 s |    .02 s |    .03 s |    .05 s |   .10 s |
`LkJson`         |     .01 s |    .02 s |    .04 s |    .10 s |   .17 s |
`System.JSON`    |     .01 s |    .09 s |    .04 s |    .07 s |   .12 s |
`JsonDataObjects`|     .01 s |    .08 s |    .26 s |   2.76 s | 15.55 s |
`JsonTools`      |     .02 s |    .12 s |    .43 s |   5.51 s | 23.87 s |
`Json4Delphi`    |     .01 s |    .02 s |    .03 s |    .06 s |   .11 s |


## Validation test
This validation test should be analyzed carefully. Some libraries have violations for some sort of self-management in reading JSON data.
- `.\test\valid` files extracted from [MJPA/SimpleJSON](https://github.com/MJPA/SimpleJSON)
- These are not valid JSON files because first line has a text as description.

Library          | Expected to Fail but Passed          | Expected to Pass but Failed   |
:----------------|-------------------------------------:|------------------------------:|
`McJSON`         |                                    - |                             - |
`LkJson`         | fail(01, 07, 08, 16, 18, 19, 20, 21) |                             - |
`System.JSON`    |                             fail(07) |                      pass(04) |
`JsonDataObjects`|         fail(01, 05, 08, 15, 18, 19) |                  pass(04, 05) |
`JsonTools`      |                 fail(01, 16, 20, 21) |                  pass(04, 05) |
`Json4Delphi`    |                                    - |      pass(01, 03, 04, 05, 06) |

List of test files names and description
- `fail01.json = \x is not a valid escape character`
- `fail02.json = Objects require colon between name/value`
- `fail03.json = Objects do not have comma separators`
- `fail04.json = Arrays don't have colon separators`
- `fail05.json = Truth is not a valid boolean value`
- `fail06.json = Strings need double quotes, not single quotes`
- `fail07.json = Line break in a string value is not valid`
- `fail08.json = Escaped line break char is still not valid`
- `fail09.json = Unclosed array`
- `fail10.json = Numbers require exponent if 'e' is there`
- `fail11.json = Only 1 sign char can precede the value`
- `fail12.json = Commas cannot close objects`
- `fail13.json = Brackets must be matching`
- `fail14.json = Double quotes must be escaped`
- `fail15.json = Key string must be quoted`
- `fail16.json = Arrays must not have comma after last value`
- `fail17.json = Arrays must have values between commas`
- `fail18.json = Nothing but whitespace can follow the root value`
- `fail19.json = Each opening bracket must be closed`
- `fail20.json = Extra comma after object`
- `fail21.json = Numbers cannot have leading 0s`
- `fail22.json = Numbers can't be hex encoded`
- `fail23.json = Decimal numbers need a digit before the dot`
- `pass01.json = General large array testing valid values`
- `pass02.json = Heavily nested array`
- `pass03.json = Nested object`
- `pass04.json = Simple string value`
- `pass05.json = Unicode character string`
- `pass06.json = From https://json.org/example.html`

## Open File test
This is a simple test to open files with any library included into this project.
This test will be used in a future update with very large JSON files (+ 100 MiB in size).


## Conclusions
For JSON with less than 1000 objects, the choice of libraries can be screened not only based on performance. Compatibility and ease of use should be a more priority criterion. 

`LkJson` has great performance and the lowest memory consumption among all tested libraries. Some changes are needed to use it with C++Builder 10.2. For some, an obstacle can be that their interfaces are more verbose for C++ usage. For example:
````cpp
JsonP = C_LK(TlkJSON::ParseText( TlkJSON::GenerateText(C_LK(Json)) ));
````

Validation tests can demonstrate that even the most modern libraries can have occasional small violations against the standard.

For older versions of `Delphi` and `C++Builder`, the `McJSON` library can be a good choice in terms of compatibility, ease of use and good performance.

This project demonstrates some of the facilities and obstacles encountered by C++Builder developers in using libraries developed for Delphi.


## Know issues
- `SuperObject` compiles but it is not working with C++Builder. Any help getting `SuperObject` working with C++Builder is appreciated.
- `JsonTools` had problems saving to file: it was truncated at object `"key25412"`.
- `JsonTools` gave a error `Root node must be an array or object` trying to load form a UTF-8 file with 50k items file from other sub-tests.


## Changes on original source code
There were necessary modifications in order to compile and run some libraries with C++Builder.
- `uLkJSON`: 
  - `{$DEFINE USE_D2009}`
  - `TlkJSONstreamed.LoadFromStream();`
  - `TlkJSONstreamed.SaveToStream();`
- `SuperObject`: 
  - `defined(VER290) or defined(VER300) or defined(VER310) or defined(VER320)`
  - `procedure FromInterface;`

