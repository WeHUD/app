package esgi.project.wehud.network;

/**
 * Helper class to handle server responses.
 *
 * @author Olivier Gonçalves
 */
public final class ServerResponse {

    private int status;
    private String content;

    ServerResponse(int status, String content) {
        this.status = status;
        this.content = content;
    }

    public int getStatus() {
        return status;
    }

    public void setStatus(int status) {
        this.status = status;
    }

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }

}
