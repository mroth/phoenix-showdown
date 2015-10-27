import com.github.mustachejava.DefaultMustacheFactory;
import com.github.mustachejava.Mustache;
import io.undertow.Undertow;
import io.undertow.server.HttpServerExchange;
import io.undertow.server.handlers.PathTemplateHandler;
import io.undertow.util.Headers;
import io.undertow.util.PathTemplateMatch;
import org.xnio.Options;

import java.io.StringWriter;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;

public class Application {

    private static final Mustache LAYOUT = new DefaultMustacheFactory().compile("layout.mustache");

    public static void main(String[] args) {
        int port = Integer.parseInt(args[0]);

        Undertow.builder()
                .addHttpListener(port, "localhost")
                .setSocketOption(Options.BACKLOG, 1024)
                .setHandler(new PathTemplateHandler().add("/{title}", Application::handleRequest))
                .build().start();
    }

    private static void handleRequest(HttpServerExchange exchange) {
        Map<String, String> parameters = exchange.getAttachment(PathTemplateMatch.ATTACHMENT_KEY).getParameters();

        Map<String, Object> scope = new HashMap<>();

        scope.put("title", parameters.get("title"));

        class Member {
            public final String name;

            public Member(String name) {
                this.name = name;
            }
        }
        scope.put("members", Arrays.asList(
                new Member("Chris McCord"),
                new Member("Matt Sears"),
                new Member("David Stump"),
                new Member("Ricardo Thompson")
        ));

        StringWriter buffer = new StringWriter();
        LAYOUT.execute(buffer, scope);

        exchange.getResponseHeaders().put(Headers.CONTENT_TYPE, "text/html");
        exchange.getResponseSender().send(buffer.toString());
    }

}
