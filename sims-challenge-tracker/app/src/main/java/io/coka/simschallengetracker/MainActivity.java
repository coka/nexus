package io.coka.simschallengetracker;

import android.app.Activity;
import android.os.Bundle;
import android.widget.ListView;

public class MainActivity extends Activity {

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    setContentView(R.layout.activity_main);
    ListView listView = (ListView) findViewById(R.id.generations_list_view);
    listView.setAdapter(new GenerationsAdapter(this));
  }
}
