see [`txt/completed.txt`](txt/completed.txt)

## Missing bad channels
10822_20140703 
11342_20150228 
11324_20141009 (run 5)


see `./03_redoMaxfilter.bash |grep missing`

## MAT files
### mismatch triggers
11313_20141104

### missing
11343_20140110

### corrupt
11318_20141029
11331_20141120
11335_20141103
11336_20141121
11350_20141204

```matlab
badmats = {...
'subjs/11318_20141029/behavior/MEG_11318_20141029_tc.mat'
'subjs/11331_20141120/behavior/MEG_11331_20141120_tc.mat'
'subjs/11335_20141103/behavior/MEG_11335_20141103_tc.mat'
'subjs/11336_20141121/behavior/MEG_11336_20141121_tc.mat'
'subjs/11350_20141204/behavior/MEG_11350_20141204_tc.mat'}
for i=badmats'; try,a=load(i{1});[ i{1} ' works'],catch,[ 'corrupt ' i{1} ],end, end
```


## MaxFilter Issues
| ld            | MEG | sss | trans  | reason |
|---------------|-----|-----|--------| ------ |
|11216_20141008 |   8 |   3 |   2    | too many tSSS |
|11353_20141230 |   8 |   0 |   1    | too many tSSS |


## Missing runs

`11287_20140522` is missing runs 7 and 8
`11324_20141009` is missing run 8

## duplicate:

11250_20140421 is mislabled by a day. should be 11250_20140422. symlinks mean both exist
