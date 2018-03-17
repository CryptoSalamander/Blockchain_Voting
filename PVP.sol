pragma solidity ^0.4.0;

contract PVP 
{
    struct PVP_VOTER
    {
        bool b_HaveRight;
        bool b_Voted;
        uint256 Vote;
        uint8 VoteWeight;
        address Delegate;
    }
    struct PVP_CANDIDATE
    {
        uint256 VoteCount;
    }
    
    address m_ContractCreator;
    mapping(address => PVP_VOTER) m_Voters;
    PVP_CANDIDATE[] m_Candidates;
    
    // Create a new PVP Vote with Different _numCandidate.
    function PVP(uint8 _numCandidate) public
    {
        m_ContractCreator = msg.sender;
        m_Voters[m_ContractCreator].b_HaveRight = true;
        m_Voters[m_ContractCreator].VoteWeight = 1;
        m_Candidates.length = _numCandidate;
    }
    
    // Give the right to join on this vote
    // Only be Called by Administrator(m_ContractCreator) 
    function GiveRightTo(address VoterAddress) public
    {
        if (msg.sender != m_ContractCreator || m_Voters[VoterAddress].b_Voted) return;
        m_Voters[VoterAddress].b_HaveRight = true;
        m_Voters[VoterAddress].VoteWeight = 1;
    }
    
    // Delegate your vote to the DelegateVoter
    function Delegate(address DelegateVoter) public
    {
        PVP_VOTER storage l_Sender = m_Voters[msg.sender];
        if (l_Sender.b_Voted) return;
        while (m_Voters[DelegateVoter].Delegate != address(0) && m_Voters[DelegateVoter].Delegate != msg.sender)
        {
            DelegateVoter = m_Voters[DelegateVoter].Delegate;
        }
        if (DelegateVoter == msg.sender) return;
        l_Sender.b_Voted = true;
        l_Sender.Delegate = DelegateVoter;
        PVP_VOTER storage l_DelegateTo = m_Voters[DelegateVoter];
        if (l_DelegateTo.b_Voted)
        {
            m_Candidates[l_DelegateTo.Vote].VoteCount += l_Sender.VoteWeight;
        }
        else
        {
            l_DelegateTo.VoteWeight += l_Sender.VoteWeight;
        }
    }
    
    // Give a Vote to Candidates toCandidate
    function Vote(uint8 toCandidate) public 
    {
        PVP_VOTER storage l_Sender = m_Voters[msg.sender];
        if (!l_Sender.b_HaveRight || l_Sender.b_Voted || toCandidate >= m_Candidates.length) return;
        l_Sender.b_Voted = true;
        l_Sender.Vote = toCandidate;
        m_Candidates[toCandidate].VoteCount += l_Sender.VoteWeight;
    }
    
    // Announce Winner!
    function WinningCandidate() public constant returns (uint8 _WinningCandidate)
    {
        uint256 l_WinningVoteCount = 0;
        for (uint8 l_Candidate = 0; l_Candidate < m_Candidates.length; l_Candidate++)
            if (m_Candidates[l_Candidate].VoteCount > l_WinningVoteCount)
            {
                l_WinningVoteCount = m_Candidates[l_Candidate].VoteCount;
                _WinningCandidate = l_Candidate;
            }
    }
    
    function GetVoteCount(uint8 _CandidateIndex) public constant returns (uint256 _VoteCount)
    {
        _VoteCount = m_Candidates[_CandidateIndex].VoteCount;
    }
    
    function IsRight(address VoterAddress) public constant returns (bool _IsRight)
    {
        _IsRight = m_Voters[VoterAddress].b_HaveRight;
    }
}