/**
* Name: Verify2021
* Based on the internal empty template. 
* Author: HuyNQ52
* Tags: Generate extra edge when we have boot A-B and B-A
*/


model Verify2021

/* Insert your model definition here */
global {
	int cSmallFarms <- 700;
	int cMediumFarms <- 250;
	int cLargeFarms <- 50;
	int cTotalFarms <- cSmallFarms + cMediumFarms + cLargeFarms;
	float vKContacts <- 0.5;		// 75% of farms were involved in animal movement
	int cDuration <- 52;			// Weeks
	float cTpDirect <- 0.6;			// Transmission probability of farms given direct contact with an infected farm
	float cTPIndirectSmall <- 0.6;	// Transmission probability of small farms given indirect contact with an infected farm
	float cTPIndirectMedium <- 0.6;	// Transmission probability of medium farms given indirect contact with an infected farm
	float cTPIndirectLarge <- 0.006;// Transmission probability of large farms given indirect contact with an infected farm

	list<float> cCRs <- [0.241, 0.236, 0.021]; 	// Contact rate: Small farm - 0.241; Medium farm: 0.236; Large farm: 0.021

	int vKTimeCull <- 53;			// Default is no culling
	float vKCR <- 1.0;				// Default is no change in contact rate
	int vKStableContact <- 1;		// After vKStableContact weeks, the contacts will be regenerated

	map vNbInfectedFarms <- [0::0, 1::1, 2::0];	// 0 infected Small farm; 1 infected Medium farm; 0 infected Large farm 

	list<list<sFarm>> vList <- [];
	list<sFarm> vPair <- [];
	float vTP <- 0.0;

	init {
		create sFarm number: cMediumFarms {
			aType <- 1;
		}
		one_of(sFarm).isInfected <- true;
		create sFarm number: cSmallFarms {
			aType <- 0;
		}
		create sFarm number: cLargeFarms {
			aType <- 2;
		}
	}

	reflex rInitContacts when: mod(cycle, vKStableContact) = 0 {
		int vTotalContacts <- int(cTotalFarms * vKContacts);
		vList <- [];
		ask sFarm {
			aListContacts <- [];
			aNbContacts <- 0;
			if vTotalContacts > 0 {
				int vNbLoop <- poisson(vKCR * cCRs[aType]);
				loop times: vNbLoop {
					loop while: true {
						sFarm vFarm <- one_of(sFarm);
						if vFarm != self and not(aListContacts contains vFarm) {
							add vFarm to: aListContacts;
							aNbContacts <- aNbContacts + 1;
							if not(vList contains [self, vFarm]) and not(vList contains [vFarm, self]) {
								add [self, vFarm] to: vList;
								vTotalContacts <- vTotalContacts - 1;
							}
							break;
						} 
					}
					if vTotalContacts <= 0 {
						break;
					}
				}
			}
		}
	}

	reflex rPause when: cycle = cDuration {
		write vNbInfectedFarms;
		write string(vNbInfectedFarms[0] + vNbInfectedFarms[1] + vNbInfectedFarms[2]); 
		write length(vList);
		do pause;
	}
}

species sFarm {
	int aType <- 3; 				// 0 - Small farm; 1 - Medium farm; 2 - Large farm
	bool isInfected <- false;
	list<sFarm> aListContacts <- [];
	int aNbContacts <- 0;

	reflex rInfection {
		if isInfected {
			loop vFarm over: aListContacts {
				if flip (0.6) and not(vFarm.isInfected) {
					vFarm.isInfected <- true;
					vNbInfectedFarms[vFarm.aType] <- vNbInfectedFarms[vFarm.aType] + 1;
				}
			}
		} else {
			loop vFarm over: aListContacts {
				if vFarm.isInfected and flip(0.6) {
					isInfected <- true;
					vNbInfectedFarms[aType] <- vNbInfectedFarms[aType] + 1;
					break;
				}
			}
		}
	}
}

experiment eExp type:gui {
	output {
		display myChart refresh: every(1 #cycles) {
			chart "Số trang trại bị nhiễm bệnh" type: series {
				data "Small" value: vNbInfectedFarms[0] color: #red;
				data "Medium" value: vNbInfectedFarms[1] color: #orange;
				data "Large" value: vNbInfectedFarms[2] color: #green; 
			}
		}
	}
}