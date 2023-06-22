

function PoliticalCandidateCard(props) {

    console.log("id at card", props.politicalCandidate.id);

    return (

        <div className="card" style={(props.politicalCandidate.winner) ? { border: "green 10px solid" } : { border: "10px solid" }}>
            <p className="d-none" id={props.politicalCandidate.id}></p>
            <h5>Candidate Name: {props.politicalCandidate.firstName} {props.politicalCandidate.lastName}</h5>
            <p>Party: {props.politicalCandidate.party}</p>
            <p>Current Votes: {props.politicalCandidate.currentVotes}</p>
            Avatar: <img style={{ width: "100px", height: "100px" }} src={props.politicalCandidate.imageUrl} alt="" />
        </div>

    );
}
export default PoliticalCandidateCard;