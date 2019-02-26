pragma solidity 0.4.25;


//Vote pour  pour demarrer le premier mois
contract Daret {
    //Nombre d'ETH a payer par mois
    uint mensualite;
    uint8 public moisCourrent;
    uint public nbParticipants;
    
    event NouveauPartitipant(address qui);
    event MoisPaye(address qui, uint8 mois);
    event TransfertCollecteMois(address beneficiaire, uint8 mois);
    
    constructor(uint _mensualiteEther, uint _nbParticipants) public {
        mensualite = _mensualiteEther * (1 ether);
        nbParticipants = _nbParticipants;
    }
    
    
    
    
    //Suivi du nombre de mois qu'a paye un participant
    mapping(address => uint8) public moisPayes;
    
    //Participants dans l'ordre de reception du pret
    address [] public participants;
    
    
    //On execute le paiement du mois et on passe  au mois suivant
    //Essaye d'executer les paiements du moi.
    //Si certain n'ont pas encore payé le passage de mois échoue
    //Si tous les mois sont payes daret s'arrete
    //retourn l'adresse du benefiicaire qui reçu ou address(0) si le paiement n'est pas possible
    function executerMoisCourrent() private {
        if (moisCourrent >= participants.length) return;
        address tourActuel = address(0);
        
        //TODO: utiliser un compteur car si beacuoup de participants
        //Cette boucle coutera beaucoups de gaz
        for (uint8 c = 0; c < participants.length; c++){
            //Il faut que tout le monde aie paye
            if(moisPayes[participants[c]]<= moisCourrent) return;
            if(c == moisCourrent) tourActuel = participants[c];
        }
        
        assert(tourActuel != address(0));
        //Payer le participant pour le mois courrent
        emit TransfertCollecteMois(tourActuel, moisCourrent);
        moisCourrent++;
        tourActuel.transfer((uint)(participants.length * mensualite));
    }
    
    // Inscrit un participant au daret
    // Doit payer la premier mensualite
    function inscription() public payable {
        require(moisCourrent == 0 && msg.value == mensualite && moisPayes[msg.sender] == 0);
        moisPayes[msg.sender] = 1;
        participants.push(msg.sender);
        emit NouveauPartitipant(msg.sender);
        //Si le nombre de participants atteint : commencer
        if(participants.length == nbParticipants) 
            executerMoisCourrent();
    }
    
    // Paye son la monsualite
    function payerMois() public payable {
        require(msg.value == mensualite && moisPayes[msg.sender] != 0);
        moisPayes[msg.sender]++; //Payer un mois de plus
        emit MoisPaye(msg.sender, moisPayes[msg.sender]);
        executerMoisCourrent();
    }
    
    function () public payable{
        revert();
    }
    
}
