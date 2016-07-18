// Longitude specific version of landnode.ks, with adjustments for body rotation whilst cruising to node and descending from node.

declare parameter peri is lorb/2.	// peri = altitude to begin descent from.
declare parameter DeorbitLongitude IS 42.	// 47 degrees sets Kerbin directly overhead, but the lander takes about 5 degrees to land.

SET DeorbitSpot TO LATLNG(0, DeorbitLongitude).
set pSpot to DeorbitSpot:position - body:position.
set aSpot to arctan2(pSpot:x,pSpot:z).

// descent orbit insertion
// prerequisite: ship in circular orbit
// move origin to central body (i.e. Mun)
set pship to V(0,0,0) - body:position.
set psun to sun:position - body:position.

// current target angular position 
set aship to arctan2(pship:x,pship:z).
set asun to arctan2(psun:x,psun:z).

// target angular position after transfer
set sma to pship:mag.                       // mun/minmus have a circular orbit
set ops to 2 * pi * sqrt(sma^3/mu).         // mun/minmus orbital period
// aim for landing zone 60 degrees before sunset
set aperi to asun - 30.                     // assume counterclockwise orbits

set aperi to aSpot.

// ship angular position for maneuver
set as0 to mod(aperi + 180, 360).
print "T+" + round(missiontime) + " Ship, orbital period: " + round(ops/60,1) + "m".
print "T+" + round(missiontime) + " | Sun: " + round(asun) + "', peri: " + round(aperi) + "', mnvr: " + round(as0) + "'".
// etam to maneuver node
set asm to as0.
until aship > asm { set asm to asm - 360. }
set etam to (aship - asm) / 360 * ops.
if etam < 60 { 
    set etam to etam + ops.
    print "T+" + round(missiontime) + " too close for maneuver, waiting for one orbit," + round(ops/60,1) + "m".
}
print "T+" + round(missiontime) + " | Ship: " + round(aship) + "', atm: " + round(aship-asm) + "', etam: " + round(etam) + "s".
// descent orbit
set smal to (pship:mag + rb + peri)/2.
set vom to velocity:orbit:mag.
set vh to sqrt( vom^2 - mu * (1/smal - 1/sma ) ).
set deltav to vh - vom.
print "T+" + round(missiontime) + " Descent orbit burn: " + round(vom) + ", dv:" + round(deltav) + " -> " + round(vh) + "m/s".
// setup node 
set nd to node(time:seconds + etam, 0, 0, deltav).
add nd.

// adjust for the body we are orbiting to rotate under us whilst we cruise to the descending node.
set shiptonodedegrees to 360 * etam / body:rotationperiod.
set adjustforshiptonodeseconds to sin(90 - ABS(ORBIT:INCLINATION)) * ops * shiptonodedegrees / 360.
// adjust for the body we are orbiting to rotate during the descent to periapsis to land with "run landv(3)." after the node is created.
set adjustfororbitdegrees to 360 * (nd:orbit:period / 2) / body:rotationperiod.	
set adjustfororbitseconds to sin(90 - ABS(nd:ORBIT:INCLINATION)) * ops * adjustfororbitdegrees / 360.

remove nd.
set nd to node(time:seconds + etam + adjustforshiptonodeseconds + adjustfororbitseconds, 0, 0, deltav).
add nd.
