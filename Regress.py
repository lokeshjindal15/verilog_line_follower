#!/usr/bin/python

import sys
import os

import Units

""" Regression script for the project"""

def runRegressions():
  for Unit in Units.UnitList:
    Unit.runUnitTests()

def RegressUnit(unitname):
  for Unit in Units.UnitList:
    if(Unit.name == unitname):
      Unit.runUnitTests()

# :D, hardcoding our first module
def main():

  Units.addUnit('a2d_intf')
  Units.addUnit('uart')
  Units.addUnit('digicore')
  Units.addUnit('follower')

  Units.addUnit('FINAL')
  #addUnit('follower_stress')

  if( len(sys.argv) == 2 and sys.argv[1] == 'all'):
    print "Regressing ALL!!!\n\n"
    runRegressions()
  elif( len(sys.argv) == 1):
    print "Regressing Top level!!!\n\n"
    RegressUnit('Follower')
  elif( len(sys.argv) == 2):
    print sys.argv[1]
    RegressUnit( sys.argv[1] )

if __name__ == '__main__':
  main()
  
