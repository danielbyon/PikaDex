msg = ["Oh no! The Pokémon broke free!", "Aww! It appeared to be caught!", "Aargh! Almost had it!", "Shoot! It was so close, too!"];
status_mods = {
   none: 1,
   psn: 1.5,
   par: 1.5,
   brn: 1.5,
   slp: 2,
   frz: 2
};
version_group = 10;

function get_catch_rate(pokemon, ball) {
   var form = $("#form").val() * 1;
   if (isNaN(form)) {
      form = 0;
   }
   var mon = get_pokemon(pokemon, form);
   var catch_rate = mon.catch_rate;

   switch (ball) {
      case 'fast-ball':
         if (mon.speed >= 100) {
            catch_rate *= 4;
         }
         break;
      case 'heavy-ball':
         var weight = mon.weight;
         if (weight >= 4096) {
            catch_rate += 40;
         }
         else if (weight >= 3072) {
            catch_rate += 30;
         }
         else if (weight >= 2048) {
            catch_rate += 20;
         }
         else {
            catch_rate -= 20;
         }
         break;
      case 'level-ball':
         var level = $("#level").val() * 1;
         var your_level = $("#your-level").val() * 1;
         if (!isNaN(your_level)) {
            if (Math.floor(your_level / 4) > level) {
               catch_rate *= 8;
            }
            else if (Math.floor(your_level / 2) > level) {
               catch_rate *= 4;
            }
            else if (your_level > level) {
               catch_rate *= 2;
            }
         }
         break;
      case 'love-ball':
         var gender = $("[name=gender]:checked").val();
         var your_gender = $("[name=your-gender]:checked").val();
         var your_pokemon = $("#your-pokemon").val() * 1;
         if (your_pokemon === pokemon && (gender === "male" && your_gender === "female" || gender === "female" && your_gender === "male")) {
            catch_rate *= 8;
         }
         break;
      case 'lure-ball':
         if ($("#fishing").prop("checked")) {
            catch_rate *= 3;
         }
         break;
      case 'moon-ball':
         if (pokemon >= 29 && pokemon <= 36 || pokemon === 39 || pokemon === 40 || pokemon === 300 || pokemon === 301) {
            catch_rate *= 4;
         }
         break;
   }

   // Fix catch rate to be between 1 and 255, the same way the game does it
   if (catch_rate > 255) {
      catch_rate = 255;
   }
   else if (catch_rate < 0) {
      catch_rate = 1;
   }
   return catch_rate;
}

function get_ball_bonus(ball) {
   var pokemon = $("#pokemon").val() * 1;
   var level = $("#level").val() * 1;
   var form = $("#form").val() * 1;
   if (isNaN(form)) {
      form = 0;
   }
   var turn = $("#turn").val() * 1;
   if (isNaN(turn)) {
      turn = 1;
   }
   var mon = get_pokemon(pokemon, form);

   switch (ball) {
      case 'great-ball':
      case 'safari-ball':
      case 'sport-ball':
         return 1.5;
      case 'ultra-ball':
         return 2;
      case 'master-ball':
      case 'park-ball':
         return -1;
      case 'net-ball':
         if ($.inArray('bug', mon.types) !== -1 || $.inArray('water', mon.types) !== -1) {
            return 3;
         }
         else {
            return 1;
         }
      case 'nest-ball':
         return Math.max(1, (40 - level) / 10);
      case 'dive-ball':
         if ($("#underwater").prop("checked")) {
            return 3.5;
         }
         else {
            return 1;
         }
      case 'repeat-ball':
         if ($("#registered").prop("checked")) {
            return 3;
         }
         else {
            return 1;
         }
      case 'timer-ball':
         return Math.min(4, ((turn - 1) + 10) / 10);
      case 'quick-ball':
         if (turn === 1) {
            return 4;
         }
         else {
            return 1;
         }
      case 'dusk-ball':
         if ($("#dark").prop("checked")) {
            return 3.5;
         }
         else {
            return 1;
         }
      default:
         return 1;
   }
}

function calc_x(m, hp, c, b, s, g, e) {
   return Math.max(1, Math.floor(Math.floor((3 * m - 2 * hp) * Math.floor(c * b) / (3 * m)) * s));
}

function calc_chances(x, c, b, s, p) {
   var chance = new ChanceObj();
   var num_x = x.length;
   for (var i = 0; i < num_x; i++) {
      if (x[i] >= 255) {
         // auto-catch
         chance.success += 1 / num_x;
         chance.comp_val = 65536;
      }
      else {
         // Using the full formula for Y
         var y = Math.floor(1048560 / Math.floor(Math.sqrt(Math.floor(Math.sqrt(16711680 / x[i])))));
         chance.comp_val = y;
         var y_chance = y / 65536;
         if (y_chance > 1) {
            // A chance greater than 100% is nonsensical, so bump it back down
            y_chance = 1;
         }
         var y_compl = 1 - y_chance;
         var success_chance = Math.pow(y_chance, 4);
         chance.success += success_chance / num_x;
         chance.wobble3 += (Math.pow(y_chance, 3) - success_chance) / num_x;
         chance.wobble2 += Math.pow(y_chance, 2) * y_compl / num_x;
         chance.wobble1 += y_chance * y_compl / num_x;
         chance.wobble0 += y_compl / num_x;
      }
   }

   return chance;
}
