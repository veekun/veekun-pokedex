<!DOCTYPE html>
<html>
<head>
    <link rel="stylesheet" type="text/css" href="${request.route_url('pyscss', css_path='archetype')}">
    <link rel="stylesheet" type="text/css" href="${request.route_url('pyscss', css_path='layout')}">
    <title><%block name="title">veekun</%block></title>
</head>
<body>
    <header id="header">
    </header>
    <section id="body">
        ${next.body()}
    </section>
    <footer id="footer">
    </footer>
</body>
</html>
