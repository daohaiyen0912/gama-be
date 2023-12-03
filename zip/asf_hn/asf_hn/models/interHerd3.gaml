/**
* Name: interHerd2
* Based on the internal empty template. 
* Author: HuyNQ52
* Tags: Initialize contacts
*/

model interHerd2

/* Insert your model definition here */
global {
	int vNbMin <- 1;
	int vNbMax <- 100;
	list<string> vExcluded <- ["sDistrict0", "sDistrict3", "sDistrict7", "sDistrict12", 
		"sDistrict27", "sDistrict10", "sDistrict23", "sDistrict13", "sDistrict17", "sDistrict2", "sDistrict9"];
	file vFQuanHuyen <- file("../includes/QuanHuyen.shp");
	file vFTinhTP <- file("../includes/TinhTP.shp");
	geometry vGeometry <- envelope(vFQuanHuyen);
	geometry shape <- envelope(vFQuanHuyen);
	int vNbHerdsInfected <- 0;
	int vNbHerdsTotal <- 0;
	int vNbPigsInfected <- 0;
	int vNbPigsTotal <- 0;
	
	init {
		create sCity from: vFTinhTP;
		create sDistrict from: vFQuanHuyen;
		write sDistrict.population;
		
		/* Initialize a infected herd */
		create sHerd number: 1 {
			sDistrict vTmp <- one_of(sDistrict);
			loop while: vExcluded contains vTmp.name {
				vTmp <- one_of(sDistrict);
			}
	    	location <- any_location_in(vTmp);
	    	isInfected <- true;
	    	vNbHerdsInfected <- vNbHerdsInfected + 1;
	    	int tmp <- rnd(0,100);
	      	if tmp <= 5 {
	      		nb_pigs <- rnd(1000, 3000);
	      	} else if tmp <= 30 {
	      		nb_pigs <- rnd(100, 999);
	      	} else {
	      		nb_pigs <- rnd(1, 99);
	      	}
	      	vNbPigsTotal <- vNbPigsTotal + nb_pigs;
	      	vNbPigsInfected <- vNbPigsInfected + nb_pigs;
	    }
		
		/* Initialize all other herds */
		sDistrict vDistrict;
		loop vDistrict over: sDistrict {
			if (not (vExcluded contains vDistrict.name)) {
				int vNbHerds <- rnd(vNbMin, vNbMax);
				loop times: vNbHerds {
					create sHerd  {
						location <- any_location_in(vDistrict);
						int tmp <- rnd(0,100);
				      	if tmp <= 5 {
				      		nb_pigs <- rnd(1000, 3000);
				      	} else if tmp <= 30 {
				      		nb_pigs <- rnd(100, 999);
				      	} else {
				      		nb_pigs <- rnd(1, 99);
				      	}
				      	vNbPigsTotal <- vNbPigsTotal + nb_pigs;
					}
				}
			}
		}
		vNbHerdsTotal <- length(sHerd.population);
		
		/* Initialize contacts */
//		int vNbContacts <- int(vNbHerdsTotal / 2);
		int vNbContacts <- int(vNbHerdsTotal * 10.0);
		list vList;
		list<sHerd> vPair;
		loop while: (vNbContacts > 0) {
			vPair <- (2 among sHerd.population);
			loop while: (vList contains vPair) {
				vPair <- (2 among sHerd.population);
			}
			
			if ((vPair at 0).nb_pigs < 100) {
				add (vPair at 0) to: (vPair at 1).aListSmall;
			} else if ((vPair at 0).nb_pigs < 1000) {
				add (vPair at 0) to: (vPair at 1).aListMedium;
			} else {
				add (vPair at 0) to: (vPair at 1).aListLarge;
			}
			
			if ((vPair at 1).nb_pigs < 100) {
				add (vPair at 1) to: (vPair at 0).aListSmall;
			} else if ((vPair at 1).nb_pigs < 1000) {
				add (vPair at 1) to: (vPair at 0).aListMedium;
			} else {
				add (vPair at 1) to: (vPair at 0).aListLarge;
			}
			
			vNbContacts <- vNbContacts - 1;
		}
	}
	
	reflex log {
			write "Day: " + cycle + " Week: " + int(cycle/7);
		}
	reflex pause when: cycle = 7 or cycle = 7 * 13 or cycle = 7 * 26 or cycle = 7*52 {
		do pause;
		}
}

species sCity {
	aspect default {
		draw shape color: #gray border: #black;
		draw name color: #black size:8 at: {location.x, location.y};
	}
}

species sDistrict {
	bool isInfected <- false;
	aspect default {
		draw shape color: isInfected ? #yellow : #gray border: #black;
		draw name color: #black size:4 at: {location.x, location.y};
	}
	reflex infected {
		ask sHerd at_distance 0 {
			if (isInfected) {
				myself.isInfected <- true;
			}
		}
	}
}

species sHerd {
	int nb_pigs <- 100;
	bool isInfected <- false;
	list<sHerd> aListSmall;
	list<sHerd> aListMedium;
	list<sHerd> aListLarge;
	aspect default {
		int tmp <-  nb_pigs < 100 ? 200 : (nb_pigs < 1000 ? 300 : 500);
	    draw circle(tmp) color: isInfected ? #red : #green; 
	}
	reflex infect when: isInfected = true{
		float vDirect;
		float vIndirect;
		if mod(cycle, 7) = 0 {
			ask target: aListSmall {
				if isInfected = false {
					if (myself.nb_pigs < 100) {
						vDirect <- 0.6 * poisson(0.072) / length(myself.aListSmall);
						vIndirect <- 0.6 * poisson(0.282) / length(myself.aListSmall);
					} else if (myself.nb_pigs < 1000) {
						vDirect <- 0.6 * poisson(0.072) / length(myself.aListSmall);
						vIndirect <- 0.6 * poisson(0.282) / length(myself.aListSmall);
					} else {
						vDirect <- 0.0;
						vDirect <- 0.0;
					}
					
					if flip(vDirect + vIndirect) {
						isInfected <- true;
						vNbHerdsInfected <- vNbHerdsInfected + 1;
						vNbPigsInfected <- vNbPigsInfected + nb_pigs;
					}
				}
			}
			
			ask target: aListMedium {
				if isInfected = false {
					if (myself.nb_pigs < 100) {
						vDirect <- 0.0;
						vIndirect <- 0.6 * poisson(0.282) / length(myself.aListMedium);
					} else if (myself.nb_pigs < 1000) {
						vDirect <- 0.6 * poisson(0.073) / length(myself.aListMedium);
						vIndirect <- 0.6 * poisson(0.271) / length(myself.aListMedium);
					} else {
						vDirect <- 0.6 * poisson(0.073) / length(myself.aListMedium);
						vIndirect <- 0.006 * poisson(0.271) / length(myself.aListMedium);
					}
					
					if flip(vDirect + vIndirect) {
						isInfected <- true;
						vNbHerdsInfected <- vNbHerdsInfected + 1;
						vNbPigsInfected <- vNbPigsInfected + nb_pigs;
					}
				}
			}
			
			ask target: aListLarge {
				if isInfected = false {
					if (myself.nb_pigs < 100) {
						vDirect <- 0.0;
						vIndirect <- 0.0;
					} else if (myself.nb_pigs < 1000) {
						vDirect <- 0.0;
						vIndirect <- 0.006 * poisson(3.5) / length(myself.aListLarge);
					} else {
						vDirect <- 0.0;
						vIndirect <- 0.006 * poisson(3.5) / length(myself.aListLarge);
					}
					
					if flip(vDirect + vIndirect) {
						isInfected <- true;
						vNbHerdsInfected <- vNbHerdsInfected + 1;
						vNbPigsInfected <- vNbPigsInfected + nb_pigs;
					}
				}
			}
		}
	}
}

experiment myExp type: gui {
	output {
		display myDisp {
			species sCity aspect: default;
			species sDistrict aspect: default;
			species sHerd aspect: default;
		}
		display myChart1 refresh: every(1 #cycles) {
			chart "Trang trại" type: series {
				data "Bị bệnh" value: vNbHerdsInfected color: #red;
				data "Không bệnh" value: vNbHerdsTotal - vNbHerdsInfected color: # green;
			}
		}
		display myChart2 refresh: every(1 #cycles) {
			chart "Số lợn" type: series {
				data "Bị bệnh" value: vNbPigsInfected color: #red;
				data "Không bệnh" value: vNbPigsTotal - vNbPigsInfected color: # green;
			}
		}
	}
}