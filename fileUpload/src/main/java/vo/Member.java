package vo;

public class Member {
	private String memberId;
	private String memberPw;
	private String updatedte;
	public String getMemberId() {
		return memberId;
	}
	public void setMemberId(String memberId) {
		this.memberId = memberId;
	}
	public String getMemberPw() {
		return memberPw;
	}
	public void setMemberPw(String memberPw) {
		this.memberPw = memberPw;
	}
	public String getUpdatedte() {
		return updatedte;
	}
	public void setUpdatedte(String updatedte) {
		this.updatedte = updatedte;
	}
	public String getCreatedate() {
		return createdate;
	}
	public void setCreatedate(String createdate) {
		this.createdate = createdate;
	}
	private String createdate;
	
}
