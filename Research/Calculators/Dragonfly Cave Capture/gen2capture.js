msg = ["Oh no! The POKéMON broke free!", "Aww! It appeared to be caught!", "Aargh! Almost had it!", "Shoot! It was so close too!"];

status_mods = {
   none: 0,
   psn: 0,
   par: 0,
   brn: 0,
   slp: 10,
   frz: 10
};
max_iv = 15;
version_group = 4;

function get_catch_rate(pokemon, ball) {
   var mon = get_pokemon(pokemon, 0);
   var catch_rate = mon.catch_rate;

   switch (ball) {
      case 'great-ball':
      case 'park-ball':
         catch_rate = Math.floor(catch_rate * 1.5);
         break;
      case 'ultra-ball':
         catch_rate *= 2;
         break;
      case 'fast-ball':
         if (pokemon === 88 || pokemon === 114 || pokemon === 81) {
            // Grimer, Tangela or Magnemite
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
         else if (weight < 1024) {
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
         if (your_pokemon === pokemon && (gender === "male" && your_gender === "male" || gender === "female" && your_gender === "female")) {
            catch_rate *= 8;
         }
         break;
      case 'lure-ball':
         if ($("#fishing").prop("checked")) {
            catch_rate *= 3;
         }
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
   if (ball === 'master-ball') {
      return -1;
   }
   else {
      return 1;
   }
}

function calc_y(x) {
   if (x <= 1) return 63;
   if (x <= 2) return 75;
   if (x <= 3) return 84;
   if (x <= 4) return 90;
   if (x <= 5) return 95;
   if (x <= 7) return 103;
   if (x <= 10) return 113;
   if (x <= 15) return 126;
   if (x <= 20) return 134;
   if (x <= 30) return 149;
   if (x <= 40) return 160;
   if (x <= 50) return 169;
   if (x <= 60) return 177;
   if (x <= 80) return 191;
   if (x <= 100) return 201;
   if (x <= 120) return 211;
   if (x <= 140) return 220;
   if (x <= 160) return 227;
   if (x <= 180) return 234;
   if (x <= 200) return 240;
   if (x <= 220) return 246;
   if (x <= 240) return 251;
   if (x <= 254) return 253;
   return 255;
}

function calc_x(max_hp, cur_hp, c, b, s, g, e) {
   var m = max_hp * 3;
   var h = cur_hp * 2;
   var is_glitched = false;

   if (m > 255) {
      m = Math.floor(m / 4);
      if (m > 255) {
         // Whoops! We're going to have some glitching on our hands!
         console.log('Glitched value!', m, Math.floor(h / 4));
         is_glitched = true;
      } else {
         console.log('Non-glitched value!', m, Math.floor(h / 4));
      }
      m = m % 256;
      h = Math.floor(h / 4) % 256;
      if (h == 0) {
         h = 1;
      }
   }

   var sub = m - h;
   if (sub < 0) {
      sub += 256;
   }

   if (m == 0) {
      return -256;
   }
   var pre_status = Math.floor(Math.max(sub * c / m, 1)) % 256;

   // Return a negative value if this is a glitched result.
   return Math.min(255, pre_status + s) * (is_glitched ? -1 : 1);
}

function calc_chances(x, c, b, s, p) {
   var chance = new ChanceObj();
   var num_x = x.length;
   var glitched = false;
   var nonglitched = false;
   var freeze = false;
   var this_x;
   for (var i = 0; i < num_x; i++) {
      if (x[i] <= 0) {
         glitched = true;
      } else {
         nonglitched = true;
      }
      this_x = Math.abs(x[i]);
      chance.comp_val = this_x;
      if (this_x == 256) {
         freeze = true;
      }
      else {
         var x_chance = (this_x + 1) / 256;
         var y_chance = calc_y(this_x) / 256;
         chance.success += x_chance / num_x;
         chance.wobble3 += (1 - x_chance) * Math.pow(y_chance, 3) / num_x;
         chance.wobble2 += (1 - x_chance) * (y_chance * y_chance * (1 - y_chance)) / num_x;
         chance.wobble1 += (1 - x_chance) * (y_chance * (1 - y_chance)) / num_x;
         chance.wobble0 += (1 - x_chance) * (1 - y_chance) / num_x;
      }
   }

   if (freeze && chance.success == 0) {
      // All possible results in this range result in an infinite loop
      chance.extra_msg = " <strong>Thanks to <a href=\"/mechanics/gen-ii-capturing\">a glitch</a>, the game will freeze and go into an infinite loop!</strong> Don't go throwing any balls at it.";
   }
   else if (glitched) {
      if (nonglitched) {
         chance.extra_msg = " <strong>This result may be glitchy!</strong>" + (freeze ? " Furthermore, depending on the Pokémon's HP IV, the game may freeze." : "") + " Please check 'Show detailed report' above for more information.";
      } else {
         chance.extra_msg = " <strong>This result is glitchy!</strong> It bumps into <a href=\"/mechanics/gen-ii-capturing\">a bug in the capture routine</a> that causes nonsensical behaviour that is not as the developers intended.";

         // We don't need to check that we're checking more than one X value
         // here, because if we weren't, the if statement above would've caught it.
         if (freeze) {
            chance.extra_msg += " Furthermore, for some HP IVs, the game will freeze.";
         }
         if (num_x > 1) {
            chance.extra_msg += " Please check 'Show detailed report' for more information.";
         }
      }
   }

   return chance;
}
