msg = ["Oh no! The Pokémon broke free!", "Aww! It appeared to be caught!", "Aargh! Almost had it!", "Shoot! It was so close, too!"];
status_mods = {
   none: 1,
   psn: 1.5,
   par: 1.5,
   brn: 1.5,
   slp: 2.5,
   frz: 2.5
};
version_group = 17;

function get_version_group() {
   var checked_game = $("input[name=game]:checked").val();
   if (checked_game === 'xy') {
      return 15;
   } else if (checked_game === 'oras') {
      return 16;
   } else if (checked_game === 'sm') {
      return 17;
   } else {
      return 18;
   }
}

function is_ultra_beast(pokemon) {
   return pokemon >= 793 && pokemon <= 799 || pokemon >= 803 && pokemon <= 806;
}

function get_catch_rate(pokemon, ball) {
   var form = $("#form").val() * 1;
   if (isNaN(form)) {
      form = 0;
   }
   var mon = get_pokemon(pokemon, form);
   var catch_rate = mon.catch_rate;

   if (ball === 'heavy-ball') {
      var weight = mon.weight;
      if (weight >= 3000) {
         catch_rate += 30;
      }
      else if (weight >= 2000) {
         catch_rate += 20;
      }
      else if (weight < 1000) {
         catch_rate -= 20;
      }
   }
   return Math.max(get_version_group() >= 18 ? 1 : 0, catch_rate);
}

function get_ball_bonus(ball) {
   var version_group = get_version_group();
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

   if (is_ultra_beast(pokemon) && ball !== 'beast-ball' && ball !== 'master-ball') {
      return 410/4096;
   }

   switch (ball) {
      case 'great-ball':
      case 'safari-ball':
         return 1.5;
      case 'ultra-ball':
         return 2;
      case 'master-ball':
         return -1;
      case 'net-ball':
         if ($.inArray('bug', mon.types) !== -1 || $.inArray('water', mon.types) !== -1) {
            return (version_group >= 17 ? 3.5 : 3);
         }
         else {
            return 1;
         }
      case 'nest-ball':
         if (level < 30) {
            return Math.max(1, (41 - level) / 10);
         } else {
            return 1;
         }
      case 'dive-ball':
         if ($("#underwater").prop("checked")) {
            return 3.5;
         }
         else {
            return 1;
         }
      case 'repeat-ball':
         if ($("#registered").prop("checked")) {
            return (version_group >= 17 ? 3.5 : 3);
         }
         else {
            return 1;
         }
      case 'timer-ball':
         return Math.min(4, 1 + ((turn - 1) * 1229/4096));
      case 'quick-ball':
         if (turn === 1) {
            return 5;
         }
         else {
            return 1;
         }
      case 'dusk-ball':
         if ($("#dark").prop("checked")) {
            return (version_group >= 17 ? 3 : 3.5);
         }
         else {
            return 1;
         }
      case 'fast-ball':
         if (mon.speed >= 100) {
            return 4;
         }
         else {
            return 1;
         }
      case 'level-ball':
         var level = $("#level").val() * 1;
         var your_level = $("#your-level").val() * 1;
         if (isNaN(your_level)) {
            return 1;
         }
         else if (Math.floor(your_level / 4) > level) {
            return 8;
         }
         else if (Math.floor(your_level / 2) > level) {
            return 4;
         }
         else if (your_level > level) {
            return 2;
         }
         else {
            return 1;
         }
      case 'love-ball':
         var gender = $("[name=gender]:checked").val();
         var your_gender = $("[name=your-gender]:checked").val();
         var your_pokemon = $("#your-pokemon").val() * 1;
         if (your_pokemon === pokemon && (gender === "male" && your_gender === "female" || gender === "female" && your_gender === "male")) {
            return 8;
         }
         else {
            return 1;
         }
      case 'lure-ball':
         if ($("#fishing").prop("checked")) {
            return (version_group >= 17 ? 5 : 3);
         }
         else {
            return 1;
         }
      case 'moon-ball':
         if (pokemon >= 29 && pokemon <= 36 || pokemon === 39 || pokemon === 40 || pokemon === 300 || pokemon === 301 || pokemon === 517 || pokemon === 518) {
            return 4;
         }
         else {
            return 1;
         }
      case 'beast-ball':
         if (is_ultra_beast(pokemon)) {
            return 5;
         }
         else {
            return 410/4096;
         }
      default:
         return 1;
   }
}

function down(x) {
   // Rounds down to the nearest 1/4096th
   return Math.floor(x * 4096) / 4096;
}

function round(x) {
   // Rounds to the nearest 1/4096th
   return Math.round(x * 4096) / 4096;
}

function calc_x(m, hp, c, b, s, g, e) {
   return Math.min(255, down(round(down(round(round((3 * m - 2 * hp) * g) * c * b) / (3 * m)) * s) * e / 100));
}

function calc_chances(x, c, b, s, p) {
   var chance_obj = new ChanceObj();
   var num_x = x.length;

   for (var i = 0; i < num_x; i++) {
      // Check for a critical capture
      var cc = Math.floor(round(round(x[i] * p) / 6));

      var crit_chance = Math.min(1, cc / 256); // Can't have a better than 100% chance of a critical capture...
      chance_obj.critical += crit_chance / num_x;

      if (x[i] >= 255) {
         // auto-catch
         chance_obj.crit_success += crit_chance / num_x;
         chance_obj.success += 1 / num_x;
         chance_obj.comp_val = 65536;
      }
      else {
         // Using the full formula for Y
         var y;
         if (x[i] == 0) {
            // Y is automatically set to zero to avoid dividing by zero
            y = 0;
         }
         else {
            y = Math.floor(round(65536 / round(Math.pow(round(255 / x[i]), 3 / 16))));
         }
         chance_obj.comp_val = y;
         var shakechance = y / 65536;
         var chance = Math.pow(shakechance, 4);

         chance_obj.crit_success += shakechance * crit_chance / num_x;
         chance_obj.success += Math.pow(shakechance, 4) / num_x;
         chance_obj.wobble3 += (Math.pow(shakechance, 3) - chance) / num_x;
         chance_obj.wobble2 += Math.pow(shakechance, 2) * (1 - shakechance) / num_x;
         chance_obj.wobble1 += shakechance * (1 - shakechance) / num_x;
         chance_obj.wobble0 += (1 - shakechance) / num_x;
      }
   }

   if (chance_obj.critical) {
      chance_obj.crit_success /= chance_obj.critical;
   }

   return chance_obj;
}
