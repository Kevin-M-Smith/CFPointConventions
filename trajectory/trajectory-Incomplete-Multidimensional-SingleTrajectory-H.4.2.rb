#! ruby

require 'numru/netcdf'
require 'fileutils'

include NumRu

base_name = File.basename(__FILE__).gsub(".rb","")
root_path = File.dirname(__FILE__) + "/" + base_name
meta_name = root_path + "/" + base_name + ".nc"
ncml_name = root_path + "/" + base_name + ".ncml"
cdl_name = root_path + "/" + base_name + ".cdl"
FileUtils.mkdir(root_path) unless File.exists?(root_path)

file = NetCDF.create(meta_name)
file.put_att("featureType","trajectory")
file.put_att("Conventions","CF-1.6")

tm = 100
name = 50

time_dim = file.def_dim("time",tm)
name_dim = file.def_dim("name_strlen",name)

lat = file.def_var("lat","sfloat",[time_dim])
lat.put_att("units","degrees_north")
lat.put_att("long_name","station latitude")
lat.put_att("standard_name","latitude")

lon = file.def_var("lon","sfloat",[time_dim])
lon.put_att("units","degrees_east")
lon.put_att("long_name","station longitude")
lon.put_att("standard_name","longitude")

trajectory_info = file.def_var("trajectory_info","int",[])
trajectory_info.put_att("long_name", "trajectory info")

trajectory_name = file.def_var("trajectory_name","char",[name_dim])
trajectory_name.put_att("cf_role", "trajectory_id")
trajectory_name.put_att("long_name", "trajectory name")

time = file.def_var("time","int",[time_dim])
time.put_att("long_name","time of measurement")
time.put_att("standard_name","time")
time.put_att("units","seconds since 1990-01-01 00:00:00")

alt = file.def_var("z","sfloat",[time_dim])
alt.put_att("long_name","height above mean sea level")
alt.put_att("standard_name","altitude")
alt.put_att("units","m")
alt.put_att("positive","up")
alt.put_att("axis","Z")

temp = file.def_var("temperature","sfloat",[time_dim])
temp.put_att("long_name","Air Temperature")
temp.put_att("standard_name","air_temperature")
temp.put_att("units","Celsius")
temp.put_att("coordinates", "time lat lon z")

humi = file.def_var("humidity","sfloat",[time_dim])
humi.put_att("long_name","Humidity")
humi.put_att("standard_name","specific_humidity")
humi.put_att("units","Percent")
humi.put_att("coordinates", "time lat lon z")

# Stop the definitions, lets write some data
file.enddef

blank = Array.new(name)
name1 = [("Trajectory1".split(//).map!{|d|d.ord} + blank)[0..name-1]]
trajectory_name.put([name1])

lat.put(NArray.float(tm).random!(45))
lon.put(NArray.float(tm).random!(-76))
time.put(NArray.int(tm).indgen!*3600)
alt.put(NArray.float(tm).indgen!)
temp.put(NArray.float(tm).random!(40))
humi.put(NArray.float(tm).random!(80))


file.close
`ncdump -h #{meta_name} > #{cdl_name}`
`ncdump -x -h #{meta_name} > #{ncml_name}`