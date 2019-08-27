# Add Partitions to Request Tracker Database Tables

```
# ./rt-partition.pl \
    --db-name=rt4_netways \
    --table=Tickets \
    --partition-add=10 \
    --consider-last=2 \
    --partition-function=mean \
    --partition-inflate=1.05 \
    --no-dry-run 

[2019-08-27 11:11:20] Use dsn: dbi:mysql:database=rt4_netways;host=localhost
[2019-08-27 11:11:20] SQL_DBMS: 5.5.5-10.0.34-MariaDB-0ubuntu0.16.04.1
[2019-08-27 11:11:20] Partition year_2001 between 20 and 1810 (items=1686)
[2019-08-27 11:11:20] Partition year_2002 between 1811 and 4251 (items=2378)
[2019-08-27 11:11:20] Partition year_2003 between 4252 and 7056 (items=2725)
[2019-08-27 11:11:20] Partition year_2004 between 7057 and 9916 (items=2635)
[2019-08-27 11:11:20] Partition year_2005 between 9917 and 12920 (items=2905)
[2019-08-27 11:11:20] Partition year_2006 between 12921 and 17987 (items=4633)
[2019-08-27 11:11:20] Partition year_2007 between 17988 and 25000 (items=5914)
[2019-08-27 11:11:20] Partition year_2008 between 25001 and 36369 (items=9408)
[2019-08-27 11:11:20] Partition year_2009 between 36371 and 48686 (items=9948)
[2019-08-27 11:11:20] Partition year_2010 between 48687 and 67793 (items=16678)
[2019-08-27 11:11:20] Partition year_2011 between 67794 and 120909 (items=28864)
[2019-08-27 11:11:20] Partition year_2012 between 120911 and 195038 (items=34033)
[2019-08-27 11:11:20] Partition year_2013 between 195040 and 276123 (items=37976)
[2019-08-27 11:11:20] Partition year_2014 between 276125 and 382131 (items=40039)
[2019-08-27 11:11:20] Partition year_2015 between 382134 and 451571 (items=24389)
[2019-08-27 11:11:20] Partition year_2016 between 451573 and 497417 (items=22926)
[2019-08-27 11:11:20] Partition year_2017 between 497419 and 544223 (items=23410)
[2019-08-27 11:11:20] Partition year_2018 between 544225 and 591843 (items=23800)
[2019-08-27 11:11:20] Partition year_2019 between 591845 and 636557 (items=24741)
[2019-08-27 11:11:20] Adding 10 more partitions with a mean of 24271 of 2 values (inflate by 1.06 each)
[2019-08-27 11:11:20] Partition year_2020 between 636557 and 660828 (items=24271)
[2019-08-27 11:11:20] Partition year_2021 between 660828 and 686555 (items=25727)
[2019-08-27 11:11:20] Partition year_2022 between 686555 and 713825 (items=27270)
[2019-08-27 11:11:20] Partition year_2023 between 713825 and 742731 (items=28906)
[2019-08-27 11:11:20] Partition year_2024 between 742731 and 773371 (items=30640)
[2019-08-27 11:11:20] Partition year_2025 between 773371 and 805849 (items=32478)
[2019-08-27 11:11:20] Partition year_2026 between 805849 and 840275 (items=34426)
[2019-08-27 11:11:20] Partition year_2027 between 840275 and 876766 (items=36491)
[2019-08-27 11:11:20] Partition year_2028 between 876766 and 915446 (items=38680)
[2019-08-27 11:11:20] Partition year_2029 between 915446 and 956446 (items=41000)
[2019-08-27 11:11:20] Generating statement
ALTER TABLE Tickets PARTITION BY RANGE(id) (
    PARTITION year_2001 VALUES LESS THAN(1810),  -- items=1686
    PARTITION year_2002 VALUES LESS THAN(4251),  -- items=2378
    PARTITION year_2003 VALUES LESS THAN(7056),  -- items=2725
    PARTITION year_2004 VALUES LESS THAN(9916),  -- items=2635
    PARTITION year_2005 VALUES LESS THAN(12920),  -- items=2905
    PARTITION year_2006 VALUES LESS THAN(17987),  -- items=4633
    PARTITION year_2007 VALUES LESS THAN(25000),  -- items=5914
    PARTITION year_2008 VALUES LESS THAN(36369),  -- items=9408
    PARTITION year_2009 VALUES LESS THAN(48686),  -- items=9948
    PARTITION year_2010 VALUES LESS THAN(67793),  -- items=16678
    PARTITION year_2011 VALUES LESS THAN(120909),  -- items=28864
    PARTITION year_2012 VALUES LESS THAN(195038),  -- items=34033
    PARTITION year_2013 VALUES LESS THAN(276123),  -- items=37976
    PARTITION year_2014 VALUES LESS THAN(382131),  -- items=40039
    PARTITION year_2015 VALUES LESS THAN(451571),  -- items=24389
    PARTITION year_2016 VALUES LESS THAN(497417),  -- items=22926
    PARTITION year_2017 VALUES LESS THAN(544223),  -- items=23410
    PARTITION year_2018 VALUES LESS THAN(591843),  -- items=23800
    PARTITION year_2019 VALUES LESS THAN(636557),  -- items=24741
    PARTITION year_2020 VALUES LESS THAN(660828),  -- items=24271
    PARTITION year_2021 VALUES LESS THAN(686555),  -- items=25727
    PARTITION year_2022 VALUES LESS THAN(713825),  -- items=27270
    PARTITION year_2023 VALUES LESS THAN(742731),  -- items=28906
    PARTITION year_2024 VALUES LESS THAN(773371),  -- items=30640
    PARTITION year_2025 VALUES LESS THAN(805849),  -- items=32478
    PARTITION year_2026 VALUES LESS THAN(840275),  -- items=34426
    PARTITION year_2027 VALUES LESS THAN(876766),  -- items=36491
    PARTITION year_2028 VALUES LESS THAN(915446),  -- items=38680
    PARTITION year_2029 VALUES LESS THAN(956446),  -- items=41000
    PARTITION year_max VALUES LESS THAN(MAXVALUE)
);
Apply statement to table "rt4_netways.Tickets" [no]: yes
[2019-08-27 11:11:22] Yes, bold decision! Applying statement
[2019-08-27 11:11:34] Successfully applied statement
```

## CLI Arguments

### --db-user

Username, default is ```root```.

### --db-name

Database name, default is ```rt4```.

### --db-host

Database host, default is ```localhost```.

### --db-port

Database port, default is not set.

### -p

Hidden prompt for password.

### --table=Tickets

Required argument for which table you want to create partitions.

### --partition-add=10

Adds partitions to the future. In this example 10 partitions .

### --consider-last=2

Use last existing partitions to calculate the future amount of tickets. The current
year is not considered. 

### --partition-function=mean

From the switch above, choose your function to calculate the base value starting from.

Possible values are: ```mean``` and ```median```.

### --partition-inflate=1.05

From the base value, add 5% to each partition

### --partition-prefix

Prefix name for partitions. Default is ```year_```.

### --created-field

Field to fetch year summaries. Default is ```Created```.

### --key-field

Key field to calculate border ranges. Default is ```id```.

### --no-dry-run

Apply the statement directly to the database after review settings.