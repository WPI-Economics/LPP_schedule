# LPP_schedule

This repo is linked to the [LPP-Updates](https://github.com/WPI-Economics/LPP-Updates) repo. Go there if you want to see how the data is compiled. It all lives in the `Update schedule` folder!

The file over there `Update schedule.r` does all the hard work, and it needs to be refreshed every month or so. It creates the `LPP_schedule_data<DATE>.RDS` file that gets read in here for the online table.

Any edits or updates to the underlying data can be done in the .csv files read into `Update schedule.r`
