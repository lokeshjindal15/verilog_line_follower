#--
#-- Unit: python module to make
#--        simulations handy

import sys
import os

# Global list of all verilog units in our project
UnitList = []

class Unit:

  name = ""                   # unit name
  unitdir = ""
  vfiles = []                 # verilog/system verilog files
  inputsets = ['test']        # default reasonably sized input set

  toplevel = ""               # * name of top level module 
  dostring = "run -all"       # change this to a custom do script if needed


  def __init__(self, _unitdir):
    if not os.path.isdir(_unitdir):
      print "Error: Cannot find the %s directory" % _unitdir
      sys.exit(1)
    self.unitdir = _unitdir

  def unit(self, _name):  # alias for adding name
    self.name = _name

  def  addfile(self, filename):
    #-- does the file exist
    fullname = self.unitdir + '/' + filename
    if not os.path.isfile(fullname):
      print "Error: file: %s does not exist" % fullname
      sys.exit(1)
    self.vfiles.append(filename)

  def toplevel(self, _toplevel):
    self.toplevel = _toplevel
  
  def add_dofile(self):
    pass

  #-- run the simulations : assuming we have $finishes in the test bench
  def runUnitTests(self):
    # check
    if len(self.vfiles) == 0:
      print "Error: no verilog files to simulate"
      sys.exit(1)

    oldpwd = os.getcwd()
    os.chdir(self.unitdir)
    print "******************************************************************"
    print "   Unit : %s" % self.name

    # build the library
    print "\n ->> Creating Work lib"
    os.system("vlib work")
    
    # add files
    print "\n ->> Building"
    os.system("vlog -sv " + " ".join(self.vfiles))

    # run simulation
    print "\n\n Running simulations for %s ..." % self.toplevel
    os.system("vsim -c -do '%s' -logfile sim.log %s" % (self.dostring , self.toplevel) )

    # todo add check

    print "\n******************************************************************\n"
    os.chdir(oldpwd)


# -- add this unit to list of all units
def addToUnits(_unit):
  UnitList.append(_unit)


#-- this script does the Unitconf reading
def addUnit(unitdir):

  unitconf = open("%s/UnitConf" % unitdir)
  unitcmds = unitconf.read().splitlines()

  _Unit = Unit(unitdir)

  for line in unitcmds:
    line = line.strip()
    if line != '':
      eval('_Unit.%s' % line)

  unitconf.close()

  addToUnits(_Unit)





