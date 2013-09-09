<%inherit file="/_base.mako" />

<script src="//ajax.googleapis.com/ajax/libs/jquery/1.8.2/jquery.min.js"></script>

<section>
    <h1>Tournament</h1>

    <p>Let's rock.</p>


    <img id="pokemon1">
    <img id="pokemon2">


    <pre id="debug"></pre>
</section>

<script>

(function() {

    var NUM_POKEMON = 649;

    var sprite_url = function(id) {
        return "http://veekun.com/dex/media/pokemon/main-sprites/black-white/" + String(id) + ".png";
    };

    // thx: http://stackoverflow.com/a/12646864/17875
    var fisher_yates_shuffle = function(array) {
        for (var i = array.length - 1; i > 0; i--) {
            var j = Math.floor(Math.random() * (i + 1));
            var temp = array[i];
            array[i] = array[j];
            array[j] = temp;
        }
    };

    // TODO oughta be more compartmentalized i guess?

    var remaining = [];
    for (var n = 1; n <= NUM_POKEMON; n++) {
        remaining.push(n);
    }

    
    console.log();




})();

</script>
