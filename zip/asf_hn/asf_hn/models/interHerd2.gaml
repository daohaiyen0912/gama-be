/**
* Name: interHerd2
* Based on the internal empty template. 
* Author: HuyNQ52
* Tags: Infected by distance 
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
	int vNbInfected <- 0;
	int vNbTotal <- 0;
	init {
		create sCity from: vFTinhTP;
		create sDistrict from: vFQuanHuyen;
		write sDistrict.population;
		
		create sHerd number: 1 {
			sDistrict vTmp <- one_of(sDistrict);
			loop while: vExcluded contains vTmp.name {
				vTmp <- one_of(sDistrict);
			}
	    	location <- any_location_in(vTmp);
	    	isInfected <- true;
	    	vNbInfected <- vNbInfected + 1;
	    }
		
		sDistrict vDistrict;
		loop vDistrict over: sDistrict {
			if (not (vExcluded contains vDistrict.name)) {
				int vNbHerds <- rnd(vNbMin, vNbMax);
				loop times: vNbHerds {
					create sHerd  {
						location <- any_location_in(vDistrict);
						int tmp <- rnd(0,100);
				      	if tmp <= 5 {
				      		nb_pigs <- 2000;
				      	} else if tmp <= 30 {
				      		nb_pigs <- 500;
				      	} else {
				      		nb_pigs <- 50;
				      	}		
					}
				}
			}
		}
		vNbTotal <- length(sHerd.population);
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
	bool isChage <- false;
	bool isInfected <- false;
	aspect default {
		int tmp <-  nb_pigs < 100 ? 200 : (nb_pigs < 1000 ? 300 : 500);
	    draw circle(tmp) color: isInfected ? #red : #green; 
	}
	reflex infect when: isInfected = true{
		if mod(cycle, 7) = 0 and isChage = false{
			ask sHerd at_distance 4500 {
				if isChage = false and isInfected = false {
					if myself.nb_pigs < 100 {
						if nb_pigs < 100 {
							if flip(0.072 * 0.6 + 0.282 * 0.6) {
								isInfected <- true;
								isChage <- true;
							}
						} else if nb_pigs < 1000 {
							if flip(0.282 * 0.6) {
								isInfected <- true;
								isChage <- true;
							}
						}
					}
					else if myself.nb_pigs < 1000 {
						if nb_pigs < 100 {
							if flip(0.072 * 0.6 + 0.282 * 0.6) {
								isInfected <- true;
								isChage <- true;
							}
						} else if nb_pigs < 1000 {
							if flip(0.073 * 0.6 + 0.271 * 0.6) {
								isInfected <- true;
								isChage <- true;
							}
						} else{
							if flip(3.5 * 0.6) {
								isInfected <- true;
								isChage <- true;
							}
						}
					} else {
						if nb_pigs > 1000 {
							if flip(3.5 * 0.6) {
								isInfected <- true;
								isChage <- true;
							}
						} else if nb_pigs > 100 {
							if flip(0.073 * 0.6 + 0.271 * 0.6) {
								isInfected <- true;
								isChage <- true;
							}
						}
					}
					if (isInfected = true) {
						vNbInfected <- vNbInfected + 1;
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
		display myChart refresh: every(1 #cycles) {
			chart "Trang trại" type: series {
				data "Bị bệnh" value: vNbInfected color: #red;
				data "Không bệnh" value: vNbTotal - vNbInfected color: # green;
			}
		}
	}
}