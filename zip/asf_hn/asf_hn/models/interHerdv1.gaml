/**
* Name: interHerdv1
* Based on the internal empty template. 
* Author: HuyNQ52
* Tags: 
*/


model interHerdv1

/* Insert your model definition here */
global {
  int nb_herds <- 1000;	
  file vFileMap <- file("../includes/TinhTP.shp"); 
  init {
    create herd number: nb_herds { 
      location <- {rnd(100), rnd(100)};
      int tmp <- rnd(0,100);
      if tmp <= 5 {
      	nb_pigs <- 2000;
      }
      else if tmp <= 30 {
      	nb_pigs <- 500;
      }
      else {
      	nb_pigs <- 50;
      }  
    }
    create block from: vFileMap {
//    create block from: vFileMap with: [type::string(read ("NATURE"))] {
//			if type="Industrial" {
//				color <- #blue ;
//			}
		}
	 
    create herd number: 1 {
    	location <- {rnd(100), rnd(100)};
    	isInfected <- true;
    }
  } 
	reflex log {
			write "Day: " + cycle + " Week: " + int(cycle/7);
		}
	reflex pause when: cycle = 7 or cycle = 7 * 13 or cycle = 7 * 26 or cycle = 7*52 {
		do pause;
		}
//	list<building> residential_buildings <- building where (each.type="Residential");
//	list<building> industrial_buildings <- building  where (each.type="Industrial") ;
}

species block {
	string type; 
	rgb color <- #gray  ;
	
	aspect base {
		draw shape color: color ;
	}
}

species herd {                      
  int nb_pigs <- 100;
  bool isChage <- false;
  bool isInfected <- false;
  aspect default {
	int tmp <-  nb_pigs < 100 ? 1 : (nb_pigs < 1000 ? 2 : 3);
    draw circle(tmp) color: isInfected ? #red : #green; 
  }
  reflex infect when: isInfected = true{
  	if mod(cycle, 7) = 0 and isChage = false{
	ask herd at_distance 10 #m {
		if isChage = false {
		if myself.nb_pigs < 100 {
			if nb_pigs < 100 {
				if flip(0.072 * 0.6 + 0.282 * 0.6) {
					isInfected <- true;
					isChage <- true;
				}
			}
			else if nb_pigs < 1000 {
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
			}
			else if nb_pigs < 1000 {
				if flip(0.073 * 0.6 + 0.271 * 0.6) {
					isInfected <- true;
					isChage <- true;
				}
			}
			else{
				if flip(3.5 * 0.6) {
					isInfected <- true;
					isChage <- true;
				}
			}
		}
		else {
			if nb_pigs > 1000 {
				if flip(3.5 * 0.6) {
					isInfected <- true;
					isChage <- true;
				}
			}
			else if nb_pigs > 100 {
				if flip(0.073 * 0.6 + 0.271 * 0.6) {
					isInfected <- true;
					isChage <- true;
				}
			}
		}
	}
	}
	}
	isChage <- true;
}
	reflex reset {
		isChage <- false;
	}
}




experiment Exp type: gui {
	parameter "Number of sows at init" var: nb_herds min: 1 max: 300;
	output {
		display map type:opengl {
			image "../includes/hanoi_map.png" refresh: false size: {100, 100};
			species herd;
			species block aspect: base;
		}

	}
}
