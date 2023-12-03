/**
* Name: Verify2021
* Based on the internal empty template. 
* Author: HuyNQ52
* Tags: Generate contacts first by random 2 Farm -> Too fast 10 days is peak
*/


model Verify2021

/* Insert your model definition here */
global {
	int cSmallFarms <- 700;
	int cMediumFarms <- 250;
	int cLargeFarms <- 50;
	int cTotalFarms <- cSmallFarms + cMediumFarms + cLargeFarms;
	float vKContacts <- 0.75;		// 75% of farms were involved in animal movement
	int cDuration <- 52;			// Weeks
	float cTpDirect <- 0.6;			// Transmission probability of farms given direct contact with an infected farm
	float cTPIndirectSmall <- 0.6;	// Transmission probability of small farms given indirect contact with an infected farm
	float cTPIndirectMedium <- 0.6;	// Transmission probability of medium farms given indirect contact with an infected farm
	float cTPIndirectLarge <- 0.006;// Transmission probability of large farms given indirect contact with an infected farm

	list<float> vCRs <- [0.241, 0.236, 0.021]; 	// Contact rate: Small farm - 0.241; Medium farm: 0.236; Large farm: 0.021

	int vKTimeCull <- 53;			// Default is no culling
	float vKCR <- 1.0;					// Default is no change in contact rate
	int vKStableContact <- 1;		// After vKStableContact weeks, the contacts will be regenerated

	map vNbInfectedFarms <- [0::0, 1::1, 2::0];	// 0 infected Small farm; 1 infected Medium farm; 0 infected Large farm 

	list<list<sFarm>> vList <- [];
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
		int vNbContacts <- int(cTotalFarms * vKContacts);
		loop while: (vNbContacts > 0) {
			list<sFarm> vPair <- (2 among sFarm.population);
			if ((not (vList contains vPair)) and 
				(not (vList contains [vPair[1], vPair[0]])))
			{
				add vPair to: vList;
				vNbContacts <- vNbContacts - 1;
			}
		}
	}

	reflex rInfect {
		loop vPair over: vList {
			if (vPair[0].isInfected and not vPair[1].isInfected) {
				vTP <- 0.6 * vCRs[vPair[1].aType];
				if flip (vTP) {
					vPair[1].isInfected <- true;
					vNbInfectedFarms[vPair[1].aType] <- vNbInfectedFarms[vPair[1].aType] + 1;
				}
			} else if (vPair[1].isInfected and not vPair[0].isInfected) {
				vTP <- 0.6 * vCRs[vPair[0].aType];
				if flip (vTP) {
					vPair[0].isInfected <- true;
					vNbInfectedFarms[vPair[0].aType] <- vNbInfectedFarms[vPair[0].aType] + 1;
				}
			}
		}
	}

	reflex rPause when: cycle = 52 {
		write vNbInfectedFarms;
		do pause;
	}
}

species sFarm {
	int aType <- 3; 				// 0 - Small farm; 1 - Medium farm; 2 - Large farm
	bool isInfected <- false;
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