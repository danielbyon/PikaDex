var wobblemsg = ["miss altogether", "wobble once", "wobble twice", "wobble three times"];
num_wobbles[0] = "Miss";
msg = ["The ball missed the POKéMON!", "Darn! The POKéMON broke free!", "Aww! It appeared to be caught!", "Shoot! It was so close too!"];

status_mods = {
   none: 0,
   psn: 5,
   par: 5,
   brn: 5,
   slp: 10,
   frz: 10
};
max_iv = 15;
version_group = 2;

function get_hp_bar_class(hp) {
   var hpfill = (hp === -1 ? 1 : hp / 100 * 48);
   if (hpfill < 10) {
      return "low_hp";
   }
   if (hpfill < 27) {
      return "medium_hp";
   }
   return "high_hp";
}

function get_version_group() {
   if ($("#game-y").is(":checked")) {
      return 2;
   } else {
      return 1;
   }
}

function get_ball_bonus(ball) {
   switch (ball) {
      case 'poke-ball':
         return 256;
      case 'great-ball':
         return 201;
      case 'ultra-ball':
      case 'safari-ball':
         return 151;
      case 'master-ball':
         return -1;
      default:
         return 256;
   }
}

// In R/B/Y, this function is used to calculate the HP factor
function calc_x(m, hp, c, b, s, gr, e) {
   // G value, the Great Ball modifier
   var g = 12;
   if (b == 201) {
      g = 8;
   }

   return Math.min(255, Math.floor(Math.floor(m*255/g)/Math.max(1, Math.floor(hp/4))));
}

function calc_chances(f, c, b, sw, p) {
   // S value, the status factor for the true formula
   var s = Math.floor(sw*2.5);

   var chance_obj = new ChanceObj();
   var num_f = f.length;
   var approx = "";
   for (var i = 0; i < num_f; i++) {
      var chance = (s + Math.min(c + 1, b - s) * (f[i] + 1) / 256) / b;

      var wobblechance = Math.floor((Math.floor((c * 100) / (b - 1)) * f[i]) / 255) + sw;
      var wobbles = 0;
      if (wobblechance >= 10) {
         wobbles++;
      }
      if (wobblechance >= 30) {
         wobbles++;
      }
      if (wobblechance >= 70) {
         wobbles++;
      }

      if (Math.abs(chance - wobblechance) < 1 || Math.abs(1 - (chance * 100) / wobblechance) < 0.2 || chance == 1 && wobblechance >= 100) {
         approx = ", with reasonable accuracy,";
      }
      else {
         approx = ", rather poorly,";
      }
      chance_obj.success += chance / num_f;
      chance_obj['wobble' + wobbles] += (1 - chance) / num_f;
      chance_obj.comp_val = f[i];
   }
   if (num_f == 1) {
      chance_obj.extra_msg = " The game estimates your chances" + approx + " to be around " + wobblechance + "%. If the capture fails" + (chance == 1 ? " (not that it will, since it's 100% and all)" : "") + ", the ball will therefore " + wobblemsg[wobbles] + ".";
   }

   return chance_obj;
}
