#--
#-- Unit: python module to make
#--        simulations handy

import sys
import os
import subprocess

# Global list of all verilog units in our project
UnitList = []

class Unit:

  name = ""                   # unit name
  unitdir = ""
  vfiles = []                 # verilog/system verilog files
  inputsets = ['test']        # default reasonably sized input set

  toplevel = ""               # * name of top level module 
  dostring = "run -all"       # change this to a custom do script if needed
  tests = []                  # names of tests to run for a multi test tb


  def __init__(self, _unitdir):
    if not os.path.isdir(_unitdir):
      print "Error: Cannot find the %s directory" % _unitdir
      sys.exit(1)
    self.unitdir = _unitdir

  def unit(self, _name):  # alias for adding name
    self.name = _name

  def addfile(self, filename, tb=False):
    #-- does the file exist
    #print filename, tb
    fullname = self.unitdir + '/' + filename
    if not os.path.isfile(fullname):
      print "Error: file: %s does not exist" % fullname
      sys.exit(1)

    if tb == True:
      os.system("rm -f %s" % self.unitdir + '/__' + filename)
      os.system("sed -e 's/\\$stop/\\$finish/g' %s > %s" % (fullname, self.unitdir + '/__' + filename))
      filename = '__' + filename

    self.vfiles.append(filename)

  def toplevel(self, _toplevel):
    self.toplevel = _toplevel
  
  def add_dofile(self):
    pass

  def addtest(self, testname):
    self.tests.append(testname)

  def addtests(self, testlist):
    self.tests.extend(testlist)

  #-- run the simulations : assuming we have $finishes in the test bench
  def runUnitTests(self):

    print "******************************************************************"
    print "   Unit : %s" % self.name

    if len(self.tests) == 0 :
      self.runSingleUnitTest()
    else:
      for test in self.tests:
        self.runSingleUnitTest(test)

    print "******************************************************************\n"

  def runSingleUnitTest(self, test=""):
    # check
    if len(self.vfiles) == 0:
      print "Error: no verilog files to simulate"
      sys.exit(1)

    docmd = self.dostring

    if test:
      testparam = " -gTEST_NAME=%s" % test
    else:
      testparam = ""

    oldpwd = os.getcwd()
    os.chdir(self.unitdir)
    print "------------------------------------------------------------------"
    if test:
      print "   Test : %s" % test

    # build the library
    print "\n ->> Creating Work lib"
    os.system("vlib work")
    
    # add files
    print "\n ->> Building"
    os.system("vlog -sv " + " ".join(self.vfiles))

    # run simulation
    print "\n\n Running simulations for %s ..." % self.toplevel
    os.system("vsim -c -do '%s' %s -logfile sim.log %s" % (docmd , testparam, self.toplevel) )

    # todo add check
    cnt = subprocess.check_output("grep -c 'ALL TESTS PASSED' sim.log", shell=True)
    if int(cnt) == 0:
      print " \n ERROR: Test Failed"
      sys.exit()
      return 0;
    else:
      print " \n Great, ALL TESTS PASSED!! %s\n" % int(cnt)


    print "------------------------------------------------------------------"
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





