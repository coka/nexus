package io.coka.simschallengetracker;

import android.content.Context;
import android.widget.ArrayAdapter;

public class GenerationsAdapter extends ArrayAdapter<String> {

  private String[] generations = new String[]{
      "Generation One: Mint",
      "Generation Two: Rose",
      "Generation Three: Yellow",
      "Generation Four: Grey",
      "Generation Five: Plum",
      "Generation Six: Orange",
      "Generation Seven: Pink",
      "Generation Eight: Peach",
      "Generation Nine: Green",
      "Generation Ten: Blue",
  };

  public GenerationsAdapter(Context context) {
    super(context, R.layout.item_generations);
    for (String g : generations) {
      add(g);
    }
  }
}
