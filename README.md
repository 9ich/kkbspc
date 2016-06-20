# kkbspc

This is the [Quake III: Arena](http://www.idsoftware.com/games/quake/quake3-arena/) BSP-to-AAS compiler (bspc).
The reachability determination has been slightly modified in an attempt to make Q3 bots navigate correctly in a 6DOF world.

Forked from: https://github.com/bnoordhuis/bspc

## Compiling

Dead simple:

	make

## Usage

Straight from the source:

	Usage:   bspc [-<switch> [-<switch> ...]]
	Example 1: bspc -bsp2aas maps/mymap?.bsp
	Example 2: bspc -bsp2aas pak0.pk3/maps/kdm*.bsp

	Switches:
	   bsp2aas  <[pakfilter/]filter.bsp>    = convert BSP to AAS
	   reach    <filter.bsp>                = compute reachability & clusters
	   cluster  <filter.aas>                = compute clusters
	   aasopt   <filter.aas>                = optimize aas file
	   aasinfo  <filter.aas>                = show AAS file info
	   output   <output path>               = set output path
	   threads  <X>                         = set number of threads to X
	   cfg      <filename>                  = use this cfg file
	   optimize                             = enable optimization
	   noverbose                            = disable verbose output
	   breadthfirst                         = breadth first bsp building
	   nobrushmerge                         = don't merge brushes
	   noliquids                            = don't write liquids to map
	   freetree                             = free the bsp tree
	   nocsg                                = disables brush chopping
	   forcesidesvisible                    = force all sides to be visible
	   grapplereach                         = calculate grapple reachabilities

## License

This program is licensed under the GNU Public License v2.0 and any later version.
