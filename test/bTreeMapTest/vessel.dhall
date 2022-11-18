let mainVessel = ../../vessel.dhall

in  mainVessel
  with dependencies = mainVessel.dependencies # [ "matchers" ]
