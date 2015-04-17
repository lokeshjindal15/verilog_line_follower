#!/usr/bin/python

import sys
import os

import Units
from Units import addUnit

""" Regression script for the project"""

def runRegressions():
  for Unit in Units.UnitList:
    Unit.runUnitTests()


# :D, hardcoding our first module
def main():

  addUnit('a2d_intf')

  runRegressions()

if __name__ == '__main__':
  main()
  
