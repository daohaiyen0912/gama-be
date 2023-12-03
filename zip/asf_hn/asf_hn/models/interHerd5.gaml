/**
* Name: interHerd2
* Based on the internal empty template. 
* Author: HuyNQ52
* Tags: 
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
	int vNbFarmsSmall <- 0;
	int vNbFarmsMedium <- 0;
	int vNbFarmsLarge <- 0;
	int vNbFarmsSmallInfected <- 0;
	int vNbFarmsMediumInfected <- 0;
	int vNbFarmsLargeInfected <- 0;
	
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
	      		vNbFarmsLarge <- vNbFarmsLarge + 1;
	      		vNbFarmsLargeInfected <- vNbFarmsLargeInfected + 1;
	      	} else if tmp <= 30 {
	      		nb_pigs <- rnd(100, 999);
	      		vNbFarmsMedium <- vNbFarmsMedium + 1;
	      		vNbFarmsMediumInfected <- vNbFarmsMediumInfected + 1;
	      	} else {
	      		nb_pigs <- rnd(1, 99);
	      		vNbFarmsSmall <- vNbFarmsSmall + 1;
	      		vNbFarmsSmallInfected <- vNbFarmsSmallInfected + 1;
	      	}
	      	vNbPigsTotal <- vNbPigsTotal + nb_pigs;
	      	vNbPigsInfected <- vNbPigsInfected + nb_pigs;
	      	vTmp.aNbFarms <- 1;
	      	vTmp.aNbFarmsInfected <- 1;
	    }
		
		/* Initialize all other herds */
		sDistrict vDistrict;
		loop vDistrict over: sDistrict {
			if (not (vExcluded contains vDistrict.name)) {
				vDistrict.aNbFarms <- 0;
				vDistrict.aNbFarmsInfected <- 0;
				int vNbHerds <- rnd(vNbMin, vNbMax);
				loop times: vNbHerds {
					create sHerd  {
						location <- any_location_in(vDistrict);
						int tmp <- rnd(0,100);
				      	if tmp <= 5 {
				      		nb_pigs <- rnd(1000, 3000);
				      		vNbFarmsLarge <- vNbFarmsLarge + 1;
				      	} else if tmp <= 30 {
				      		nb_pigs <- rnd(100, 999);
				      		vNbFarmsMedium <- vNbFarmsMedium + 1;
				      	} else {
				      		nb_pigs <- rnd(1, 99);
				      		vNbFarmsSmall <- vNbFarmsSmall + 1;
				      	}
				      	vNbPigsTotal <- vNbPigsTotal + nb_pigs;
				      	vDistrict.aNbFarms <- vDistrict.aNbFarms + 1;
					}
				}
			}
		}
		vNbHerdsTotal <- length(sHerd.population);
		
		/* Initialize contacts */
//		int vNbContacts <- int(vNbHerdsTotal / 2);
		int vNbContacts <- int(vNbHerdsTotal * 8.0);
		list vList <- [];
		list<sHerd> vPair;
		loop while: (vNbContacts > 0) {
			bool vCheck <- true;
			loop while: vCheck {
				vPair <- (2 among sHerd.population);
				if ((vList contains vPair) or ((vPair at 0).nb_pigs < 100 and (vPair at 1).nb_pigs > 1000) or ((vPair at 0).nb_pigs > 1000 and (vPair at 1).nb_pigs < 100)) {
					vCheck <- true;
				} else {
					vCheck <- false;
				}
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
		
		/* Write to file */
		save ("Contact list for the 2 first herds:") to: "../includes/contacts.txt" type: "text" rewrite: true;
		save ("1. Number pigs of the first herd: " + (sHerd.population at 0).nb_pigs) to: "../includes/contacts.txt" type: "text" rewrite: false;
		save ("1. Connected Small farms: " + (sHerd.population at 0).aListSmall) to: "../includes/contacts.txt" type: "text" rewrite: false;
		save ("1. Connected Medium farms: " + (sHerd.population at 0).aListMedium) to: "../includes/contacts.txt" type: "text" rewrite: false;
		save ("1. Connected Large farms: " + (sHerd.population at 0).aListLarge) to: "../includes/contacts.txt" type: "text" rewrite: false;
		save ("\n2. Number pigs of the second herd: " + (sHerd.population at 1).nb_pigs) to: "../includes/contacts.txt" type: "text" rewrite: false;
		save ("2. Connected Small farms: " + (sHerd.population at 1).aListSmall) to: "../includes/contacts.txt" type: "text" rewrite: false;
		save ("2. Connected Medium farms: " + (sHerd.population at 1).aListMedium) to: "../includes/contacts.txt" type: "text" rewrite: false;
		save ("2. Connected Large farms: " + (sHerd.population at 1).aListLarge) to: "../includes/contacts.txt" type: "text" rewrite: false;
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
		draw name color: #brown size:8 at: {location.x, location.y};
	}
}

species sDistrict {
	bool isInfected <- false;
	int aNbFarms <- 0;
	int aNbFarmsInfected <- 0;
	bool isDone <- false;
	reflex infected {
		isDone <- false;
		aNbFarmsInfected <- 0;
		ask sHerd at_distance 0 {
			if (isInfected) {
				myself.isInfected <- true;
				myself.aNbFarmsInfected <- myself.aNbFarmsInfected + 1;
			}
		}
		isDone <- true;
	}
	aspect default {
		if isDone {
			if (aNbFarms = 0) {
				draw shape color: #gray border: #black;
			} else {
				draw shape color: isInfected ? hsb(aNbFarmsInfected/aNbFarms*(0.71-0.47)+0.47, 1, 1) : #gray border: #black;
			}
			draw name color: #black size:4 at: {location.x, location.y};	
		}
	}
}

species sHerd {
	int nb_pigs <- 100;
	bool isChage <- false;
	bool isInfected <- false;
	list<sHerd> aListSmall <- [];
	list<sHerd> aListMedium <- [];
	list<sHerd> aListLarge <- [];
	aspect default {
		int tmp <-  nb_pigs < 100 ? 200 : (nb_pigs < 1000 ? 300 : 500);
	    draw circle(tmp) color: isInfected ? #red : #green; 
	}
	reflex infect when: isInfected = true{
		float vDirect;
		float vIndirect;
		if isChage = false{
			ask target: aListSmall {
				if isChage = false and isInfected = false {
					if (myself.nb_pigs < 100) {
						vDirect <- 0.6 * poisson(0.072) / length(myself.aListSmall) / 7;
						vIndirect <- 0.6 * poisson(0.282) / length(myself.aListSmall) / 7;
					} else if (myself.nb_pigs < 1000) {
						vDirect <- 0.6 * poisson(0.072) / length(myself.aListSmall) / 7;
						vIndirect <- 0.6 * poisson(0.282) / length(myself.aListSmall) / 7;
					} else {
						vDirect <- 0.0;
						vDirect <- 0.0;
					}
					
					if flip(vDirect + vIndirect) {
						isInfected <- true;
						isChage <- true;
						vNbHerdsInfected <- vNbHerdsInfected + 1;
						vNbPigsInfected <- vNbPigsInfected + nb_pigs;
						vNbFarmsSmallInfected <- vNbFarmsSmallInfected + 1;
						
					}
				}
			}
			
			ask target: aListMedium {
				if isChage = false and isInfected = false {
					if (myself.nb_pigs < 100) {
						vDirect <- 0.0;
						vIndirect <- 0.6 * poisson(0.282) / length(myself.aListMedium) / 7;
					} else if (myself.nb_pigs < 1000) {
						vDirect <- 0.6 * poisson(0.073) / length(myself.aListMedium) / 7;
						vIndirect <- 0.6 * poisson(0.271) / length(myself.aListMedium) / 7;
					} else {
						vDirect <- 0.6 * poisson(0.073) / length(myself.aListMedium) / 7;
						vIndirect <- 0.006 * poisson(0.271) / length(myself.aListMedium) / 7;
					}
					
					if flip(vDirect + vIndirect) {
						isInfected <- true;
						isChage <- true;
						vNbHerdsInfected <- vNbHerdsInfected + 1;
						vNbPigsInfected <- vNbPigsInfected + nb_pigs;
						vNbFarmsMediumInfected <- vNbFarmsMediumInfected + 1;
					}
				}
			}
			
			ask target: aListLarge {
				if isChage = false and isInfected = false {
					if (myself.nb_pigs < 100) {
						vDirect <- 0.0;
						vIndirect <- 0.0;
					} else if (myself.nb_pigs < 1000) {
						vDirect <- 0.0;
						vIndirect <- 0.006 * poisson(3.5) / length(myself.aListLarge) / 7;
					} else {
						vDirect <- 0.0;
						vIndirect <- 0.006 * poisson(3.5) / length(myself.aListLarge) / 7;
					}
					
					if flip(vDirect + vIndirect) {
						isInfected <- true;
						isChage <- true;
						vNbHerdsInfected <- vNbHerdsInfected + 1;
						vNbPigsInfected <- vNbPigsInfected + nb_pigs;
						vNbFarmsLargeInfected <- vNbFarmsLargeInfected + 1;
					}
				}
			}
		}
		isChage <- false;
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
		display myChart3 refresh: every(1 #cycles) {
			chart "Phần trăm trang trại bị nhiễm bệnh" type: series {
				data "Small" value: vNbFarmsSmallInfected/vNbFarmsSmall color: #red;
				data "Medium" value: vNbFarmsMediumInfected/vNbFarmsMedium color: #orange;
				data "Large" value: vNbFarmsLargeInfected/vNbFarmsLarge color: #green;
			}
		}
	}
}