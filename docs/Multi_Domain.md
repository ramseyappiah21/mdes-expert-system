# Ten domains in one program

The brief listed suggested domains. This project implements **all of them** in a single SWI-Prolog system. The hub (`src/hub.pl`) selects a knowledge base; it does not mix rules across domains.

| Domain | Backward goal | Recursive structure | Forward result |
| --- | --- | --- | --- |
| Academic advising | `eligible_for/2` | Prerequisite ancestor chain | Standing, unlocks, actions |
| Medical | `med_likely/2` | Complication chain | Ranked conditions, emergency flag |
| Career | `career_suitable/2` | Promotion ladder | Matching jobs |
| Library | `lib_suitable/2` | Broader-topic tree | Matching titles |
| Cybersecurity | `cy_likely/2` | Kill-chain stages | Playbook actions |
| Farming | `farm_suitable/2` | Crop-rotation paths | Suitable crops and actions |
| Vehicle | `veh_likely/2` | Component dependency | Suspected faults |
| Hotel | `hotel_suitable/2` | City/region containment | Matching hotels |
| Legal | `legal_likely/2` | Court appeal hierarchy | Matter type and next steps |
| Admission | `adm_eligible/2` | SHS-track feeder closure | Eligible programmes |

Source files live in `src/domains/` except academic advising, which remains the original CAAES core.
