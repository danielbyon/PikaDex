msg = ["Oh no! The Pokémon broke free!", "Aww! It appeared to be caught!", "", "Aargh! Almost had it!"];
status_mods = {
   none: 1,
   psn: 1.5,
   par: 1.5,
   brn: 1.5,
   slp: 2.5,
   frz: 2.5
};
version_group = 14;

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
         return 1.5;
      case 'ultra-ball':
         return 2;
      case 'master-ball':
      case 'dream-ball':
         return -1;
      case 'net-ball':
         if ($.inArray('bug', mon.types) !== -1 || $.inArray('water', mon.types) !== -1) {
            return 3;
         }
         else {
            return 1;
         }
      case 'nest-ball':
         return Math.max(1, (41 - level) / 10);
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
            return 3.5;
         }
         else {
            return 1;
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
            y = Math.floor(round(65536 / round(Math.sqrt(round(Math.sqrt(round(255 / x[i])))))));
         }
         chance_obj.comp_val = y;
         var shakechance = y / 65536;
         var chance = Math.pow(shakechance, 3);

         chance_obj.crit_success += shakechance * crit_chance / num_x;
         chance_obj.success += Math.pow(shakechance, 3) / num_x;
         chance_obj.wobble3 += (Math.pow(shakechance, 2) - chance) / num_x;
         chance_obj.wobble1 += shakechance * (1 - shakechance) / num_x;
         chance_obj.wobble0 += (1 - shakechance) / num_x;
      }
   }

   chance_obj.crit_success /= chance_obj.critical;

   return chance_obj;
}
