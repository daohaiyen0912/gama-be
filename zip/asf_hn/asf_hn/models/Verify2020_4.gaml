/**
* Name: Verify2020
* Based on the internal empty template. 
* Author: HuyNQ52
* Tags: Verify Contact rate
*/


model Verify2020

/* Insert your model definition here */

global {
//	list<int> cNbFarms <- [5499, 1989, 394];		// 5499 Small farms; 1989 Medium farms; 394 Large farms
	list<int> cNbFarms <- [700, 250, 50];
	float cTPDirect <- 0.6; 						// Transmission probability of direct contact
	list<float> cTPIndirect <- [0.6, 0.6, 0.006];	// TP of indirect contact: Small/Medium farms - 0.6; Large farms - 0.006	
	// list<int> cDuration <- [52, 11, 4];				// Infectious duration for: Small farm - 52 weeks; Medium farm - 10-12 weeks; Large farm - 4 weeks
	
	
	matrix vCRDirect 	<- matrix([[0.072, 0, 0], [0.072, 0.073, 0], [0, 0.073, 0]]); // Mean direct contact rate/week. vCRDirect[2,1] - Mean direct contact rate of Large farm to Medium farm = 0.073
	matrix vCRIndirect 	<- matrix([[0.282, 0.282, 0], [0.282, 0.271, 3.5], [0, 0.271, 3.5]]); // Mean indirect contact rate/week. vCRIndirect[2,1] - Mean indirect contact rate of Large farm to Medium farm = 0.271
	
	bool pEnDirect <- true;
	bool pEnLarge <- true;
	float pKTPIndirect <- 1.0; 	// Indirect TP change - New indirect TP = vKIndirect * old indirect TP
	float pKMove <- 1.0;			// Movement control rate - 1: No movement restriction; 0: Movement restriction 100%	
	// int vMoveRTime <- 4;		// Movement restriction within 4 weeks of detection of outbreaks 
	
	// int vCullTime <- 53;		// Culling within 53 weeks of detection of outbreaks. It mean no culling in the simulation time

	int vNbContacts <- 0;
	map vNbInfectedFarms <- [0::0, 1::1, 2::0];

	matrix verifyCRDirect 	<- matrix([[0.0, 0, 0], [0.0, 0.0, 0], [0, 0.0, 0]]);
	matrix verifyCRIndirect <- matrix([[0.0, 0.0, 0], [0.0, 0.0, 0.0], [0, 0.0, 0.0]]);

	init {
		/* Initialize farms */
		create sFarm number: cNbFarms[1] {
			aType <- 1;
		}
		sFarm vFarm <- one_of(sFarm);
		vFarm.isInfected <- true;
		write vFarm.name;
		// one_of(sFarm).isInfected <- true;
		create sFarm number: cNbFarms[0] {
			aType <- 0;
		}
		create sFarm number: cNbFarms[2] {
			aType <- 2;
		}
	}

	reflex rParseParams when: cycle = 0 {
		if !pEnDirect {
			write "Disable Direct contacts";
			vCRDirect 	<- matrix([[0.0, 0, 0], [0.0, 0.0, 0], [0, 0.0, 0]]);
		}
		if !pEnLarge {
			write "Disable contacts of Large farms";
			vCRDirect 	<- matrix([[0.072, 0, 0], [0.072, 0.073, 0], [0, 0.0, 0]]);
			vCRIndirect <- matrix([[0.282, 0.282, 0], [0.282, 0.271, 0], [0, 0.0, 0.0]]);
		}
		loop i from: 0 to: 2 {
			loop j from: 0 to: 2 {
				vCRDirect[i,j] 		<- pKMove * vCRDirect[i,j];
				vCRIndirect[i,j] 	<- pKMove * vCRIndirect[i,j];
			}
		}
	}

	reflex rInitContacts {
		vNbContacts <- 0;
		int verifyDirectContacts <- 0;
		int verifyIndirectContacts <- 0;
		int verifyNbContacts <- 0;
		int vTmp <- 0;
		ask sFarm {
			/* Regenerate number of contacts */
			loop i from: 0 to: 2 {
				aNbDirect[i] 	<- poisson(vCRDirect[aType, i]);
				aNbIndirect[i] 	<- poisson(vCRIndirect[i, aType]);
				vNbContacts <- vNbContacts + aNbDirect[i];
				vNbContacts <- vNbContacts + aNbIndirect[i];
				verifyDirectContacts <- verifyDirectContacts + aNbDirect[i];
				verifyIndirectContacts <- verifyIndirectContacts + aNbIndirect[i];
				verifyCRDirect[aType, i] <- verifyCRDirect[aType, i] + aNbDirect[i];
				verifyCRIndirect[i, aType] <- verifyCRIndirect[i, aType] + aNbIndirect[i];
			}
		}

		/* Create contacts */
		ask sFarm {
			/* Create direct contacts */
			loop i from: 0 to: 2 {
				vTmp <- vTmp + aNbDirect[i] - length(aDirect[i]);
				loop times: aNbDirect[i] - length(aDirect[i]) {
					loop while: true {
						sFarm vFarm <- one_of(sFarm); // TODO: at_distance cRange
						if vFarm != self and vFarm.aType = i and not(aDirect[i] contains vFarm) {
							add vFarm to: aDirect[i];
							break;
						}
					}
				}
				verifyNbContacts <- verifyNbContacts + length(aDirect[i]);
			}

			/* Create indirect contacts */
			loop i from: 0 to: 2 {
				vTmp <- vTmp + aNbIndirect[i] - length(aIndirect[i]);
				loop times: aNbIndirect[i] - length(aIndirect[i]) {
					loop while: true {
						sFarm vFarm <- one_of(sFarm); // TODO: at_distance cRange
						if vFarm != self and (vFarm.aType = i) and not(aIndirect[i] contains vFarm) {
							add vFarm to: aIndirect[i];
							break;
						}
					}
				}
				verifyNbContacts <- verifyNbContacts + length(aIndirect[i]);
			}
			// write aIndirect; 
		}
		write "Number of contacts: " + string(vNbContacts) + " " + string(verifyNbContacts) + " = " + string(verifyDirectContacts) + " + " + string(verifyIndirectContacts) + " " + string(vTmp);
		// do pause;
	}

	reflex rPause when: cycle = 52 {
		write vNbInfectedFarms;
		loop i from: 0 to: 2 {
			loop j from: 0 to: 2 {
				if vCRDirect[i,j] > 0 {
					float vActual <- verifyCRDirect[i,j]/cNbFarms[i]/52;
					write "Direct: " + string(i) + string(j) + " Expect: " + vCRDirect[i,j] + " - Actual: " + vActual + " - Error: " +  (abs(vActual - vCRDirect[i,j])*100/vCRDirect[i,j]) with_precision 2 + " %";
				} else {
					write "Direct: " + string(i) + string(j) + " Expect: 0 - verifyCRDirect[i,j]= " + verifyCRDirect[i,j];
				}
				
				if vCRIndirect[i,j] > 0 {
					float vActual <- verifyCRIndirect[i,j]/cNbFarms[j]/52;
					write "Indirect: " + string(i) + string(j) + " Expect: " + vCRIndirect[i,j] + " - Actual: " + vActual + " - Error: " +  (abs(vActual - vCRIndirect[i,j])*100/vCRIndirect[i,j]) with_precision 2 + " %";
				} else {
					write "Indirect: " + string(i) + string(j) + " Expect: 0 - verifyCRIndirect[i,j]= " + verifyCRIndirect[i,j];
				}
				
			}
		}
		do pause;
	}
}

species sFarm {
	int aType <- 3; 	// 0 - Small farm; 1 - Medium farm; 2 - Large farm
	bool isInfected <- false;
	map<int,list<sFarm>> aDirect 	<- [0::[], 1::[], 2::[]];
	map<int,list<sFarm>> aIndirect 	<- [0::[], 1::[], 2::[]];
	map<int,int> aNbDirect 			<- [0::0, 1::0, 2::0];
	map<int,int> aNbIndirect 		<- [0::0, 1::0, 2::0];

	reflex rInfected when: !isInfected {
		loop i from: 0 to: 2 {
			loop vFarm over: (aNbIndirect[i] among aIndirect[i]) {
				if vFarm.isInfected {
					// write name + " " + string(aNbIndirect) + " " + string(cTPIndirect[aType]);
					if flip(cTPIndirect[aType]) {
						isInfected <- true;
						vNbInfectedFarms[aType] <- vNbInfectedFarms[aType] + 1;
						break;
					}
				}
			}
			if isInfected {
				break;
			}
		}
	}

	reflex rInfect when: isInfected {
		loop i from: 0 to: 2 {
			loop vFarm over: (aNbDirect[i] among aDirect[i]) {
				if not(vFarm.isInfected) {
					if flip(cTPDirect) {
						vFarm.isInfected <- true;
						vNbInfectedFarms[vFarm.aType] <- vNbInfectedFarms[vFarm.aType] + 1;
					}
				}
			}
		}
	}
	
}

experiment eExp {
	parameter "Direct contact: " 	category: "Parameters" var: pEnDirect 	<- true;
	parameter "Large farm: " 		category: "Parameters" var: pEnLarge 	<- true;
	output {
		display myChart refresh: every(1 #cycles) {
			chart "Số trang trại bị nhiễm bệnh" {
				data "Small" value: vNbInfectedFarms[0] color: #red;
				data "Medium" value: vNbInfectedFarms[1] color: #orange;
				data "Large" value: vNbInfectedFarms[2] color: #green;
				data "Total" value: vNbInfectedFarms[0] + vNbInfectedFarms[1] + vNbInfectedFarms[2] color: #black;
			}
		}
	}
}