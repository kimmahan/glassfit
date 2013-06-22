<!--
Copyright (C) 2013 Google Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
-->
<%@ page import="com.google.api.client.auth.oauth2.Credential" %>
<%@ page import="com.google.api.services.mirror.model.Contact" %>
<%@ page import="com.google.glassware.MirrorClient" %>
<%@ page import="com.google.glassware.WebUtil" %>
<%@ page
    import="java.util.List" %>
<%@ page import="com.google.api.services.mirror.model.TimelineItem" %>
<%@ page import="com.google.api.services.mirror.model.Subscription" %>
<%@ page import="com.google.api.services.mirror.model.Attachment" %>
<%@ page import="com.google.glassware.MainServlet" %>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<!doctype html>
<%
  String userId = com.google.glassware.AuthUtil.getUserId(request);
  String appBaseUrl = WebUtil.buildUrl(request, "/");

  Credential credential = com.google.glassware.AuthUtil.getCredential(userId);

  Contact contact = MirrorClient.getContact(credential, MainServlet.CONTACT_NAME);

  List<TimelineItem> timelineItems = MirrorClient.listItems(credential, 3L).getItems();


  List<Subscription> subscriptions = MirrorClient.listSubscriptions(credential).getItems();
  boolean timelineSubscriptionExists = false;
  boolean locationSubscriptionExists = false;


  if (subscriptions != null) {
    for (Subscription subscription : subscriptions) {
      if (subscription.getId().equals("timeline")) {
        timelineSubscriptionExists = true;
      }
      if (subscription.getId().equals("locations")) {
        locationSubscriptionExists = true;
      }
    }
  }
  
%>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>GlassFit Pro Photo Meal Tracking</title>
  <link href="/static/bootstrap/css/bootstrap.min.css" rel="stylesheet" media="screen">
  <link href="/static/css/style.css" rel="stylesheet" media="screen">
  <link rel = "shortcut icon" href="favicon.ico" type="image/x-icon">
  <link rel = "icon" href="favicon.ico" type="image/x-icon">
</head>
<body>
<div class="navbar navbar-inverse navbar-fixed-top">
  <div class="navbar-inner">
    <div class="container">
      <a href="http://glassfitpro.co"><img src="static/images/logo75.png"></a>

      <div class="nav-collapse collapse">
        <form class="navbar-form pull-right" action="/signout" method="post">
          <button type="submit" class="btn">Sign out</button>
        </form>
      </div>
      <!--/.nav-collapse -->
    </div>
  </div>
</div>

<div class="container">

  <!-- Main hero unit for a primary marketing message or call to action -->
  <div class="hero-unit">
    <h2>Most Recent GlassFit Updates</h2>
    <% String flash = WebUtil.getClearFlash(request);
      if (flash != null) { %>
    <span class="label label-warning">Message: <%= flash %> </span>
    <% } %>

    <div style="margin-top: 5px;">

      <% if (timelineItems != null) {
        for (TimelineItem timelineItem : timelineItems) { %>
      <ul class="span3 tile">
        <!--<li><strong>ID: </strong> <%= timelineItem.getId() %>
        </li>-->
        <% if (timelineItem.getText() != null) { %>
        <li>
          <strong>Text: </strong> <%= timelineItem.getText() %>
        </li>
        <% } %>
        <% if (timelineItem.getHtml() != null) { %>
        <li>
          <strong>HTML: </strong> <%= timelineItem.getHtml() %>
        </li>
        <% } %>
        <% if (timelineItem.getAttachments() != null) { %>
        <li>
          <strong>Attachments: </strong>
          <%
          if (timelineItem.getAttachments() != null) {
            for (Attachment attachment : timelineItem.getAttachments()) {
              if (MirrorClient.getAttachmentContentType(credential, timelineItem.getId(), attachment.getId()).startsWith("image")) { %>
          <img src="<%= appBaseUrl + "attachmentproxy?attachment=" +
            attachment.getId() + "&timelineItem=" + timelineItem.getId() %>">
          <% } else { %>
          <a href="<%= appBaseUrl + "attachmentproxy?attachment=" +
            attachment.getId() + "&timelineItem=" + timelineItem.getId() %>">Download</a>
          <% }
            }
          } %>
        </li>
        <% } %>

      </ul>
      <% }
      } %>
    </div>
    <div style="clear:both;"></div>
  </div>

  <div class="row center calorie-count">
  	<h5><i>input the total number of calories you are aiming to maintain per day</i></h5>
  	<h2 class="inline">Total Daily Calorie Aspiration: </h2><input placeholder="1500" class="inline" style="width:200px" /> calories
  </div>
  
  <hr>

  <!-- Example row of columns -->
  <div class="row">
    <div class="span4">
      <h2>Timeline</h2>

      <p>Examples of timeline APIs</p>


      <form action="<%= WebUtil.buildUrl(request, "/main") %>" method="post">
        <input type="hidden" name="operation" value="insertItem">
        <textarea name="message">Send a custom message.</textarea><br/>
        <button class="btn" type="submit">The above message</button>
      </form>

      <form action="<%= WebUtil.buildUrl(request, "/main") %>" method="post">
        <input type="hidden" name="operation" value="insertItem">
        <input type="hidden" name="message" value="Your meal was recorded">
        <input type="hidden" name="imageUrl" value="<%= appBaseUrl +
               "static/images/lunch.jpg" %>">
        <input type="hidden" name="contentType" value="image/jpeg">

        <button class="btn" type="submit">A picture
          <img class="button-icon" src="<%= appBaseUrl +
               "static/images/lunch.jpg" %>">
        </button>
      </form>
      <form action="<%= WebUtil.buildUrl(request, "/main") %>" method="post">
        <input type="hidden" name="operation" value="insertItemWithAction">
        <button class="btn" type="submit">A card you can reply to</button>
      </form>
      <hr>
      <form action="<%= WebUtil.buildUrl(request, "/main") %>" method="post">
        <input type="hidden" name="operation" value="insertItemAllUsers">
        <button class="btn" type="submit">A card to all users</button>
      </form>

    </div>

    <div class="span4">
      <h2>Contacts</h2>

      <% if (contact == null) { %>
      <form class="span3" action="<%= WebUtil.buildUrl(request, "/main") %>"
            method="post">
        <input type="hidden" name="operation" value="insertContact">
        <input type="hidden" name="iconUrl" value="<%= appBaseUrl +
               "static/images/chipotle-tube-640x360.jpg" %>">
        <input type="hidden" name="name"
               value="<%= MainServlet.CONTACT_NAME %>">
        <button class="btn" type="submit">Insert GlassFit Contact
        </button>
      </form>
      <% } else { %>
      <form class="span3" action="<%= WebUtil.buildUrl(request, "/main") %>"
            method="post">
        <input type="hidden" name="operation" value="deleteContact">
        <input type="hidden" name="id" value="<%= MainServlet.CONTACT_NAME %>">
        <button class="btn" type="submit">Delete GlassFit Contact
        </button>
      </form>
      <% } %>
    </div>

    <div class="span4">
      <h2>Subscriptions</h2>

      <p class="label label-info">Note: Subscriptions require SSL. <br>They will
        not work on localhost.</p>

      <% if (timelineSubscriptionExists) { %>
      <form action="<%= WebUtil.buildUrl(request, "/main") %>"
            method="post">
        <input type="hidden" name="subscriptionId" value="timeline">
        <input type="hidden" name="operation" value="deleteSubscription">
        <button class="btn" type="submit" class="delete">Unsubscribe from
          timeline updates
        </button>
      </form>
      <% } else { %>
      <form action="<%= WebUtil.buildUrl(request, "/main") %>" method="post">
        <input type="hidden" name="operation" value="insertSubscription">
        <input type="hidden" name="collection" value="timeline">
        <button class="btn" type="submit">Subscribe to timeline updates</button>
      </form>
      <% }%>

      <% if (locationSubscriptionExists) { %>
      <form action="<%= WebUtil.buildUrl(request, "/main") %>"
            method="post">
        <input type="hidden" name="subscriptionId" value="locations">
        <input type="hidden" name="operation" value="deleteSubscription">
        <button class="btn" type="submit" class="delete">Unsubscribe from
          location updates
        </button>
      </form>
      <% } else { %>
      <form action="<%= WebUtil.buildUrl(request, "/main") %>" method="post">
        <input type="hidden" name="operation" value="insertSubscription">
        <input type="hidden" name="collection" value="locations">
        <button class="btn" type="submit">Subscribe to location updates</button>
      </form>
      <% }%>
    </div>
  </div>
</div>

<script
    src="//ajax.googleapis.com/ajax/libs/jquery/1.9.1/jquery.min.js"></script>
<script src="/static/bootstrap/js/bootstrap.min.js"></script>
</body>
</html>
