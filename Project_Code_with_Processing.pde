import java.util.Date;
import java.text.SimpleDateFormat;

PImage sunImage, cloudImage, rainImage, stormImage, snowImage, bgImage;
JSONObject weatherData, uvData;
Button refreshButton, celsiusButton, fahrenheitButton;
TextField cityInput;
String apiKey = "f748cb84e42e8b8b84ef595f209ef696";
boolean isCelsius = true;

void setup() {
  size(700, 700);
  sunImage = loadImage("sun.png");  
  cloudImage = loadImage("cloud.png");
  rainImage = loadImage("rain.png");
  stormImage = loadImage("storm.png");
  snowImage = loadImage("snow.png");

  cityInput = new TextField(width / 2 - 150, 30, 300, 40);
  cityInput.setText("Istanbul");
  cityInput.setFocus(true);
  cityInput.setPlaceholder("Enter city name...");
  
  buttonSetup();
}

void draw() {
  background(#4EA8DE);
  
  cityInput.draw();
  
  if (weatherData != null) {
    displayWeatherData();
  }
  
  refreshButton.update();
  refreshButton.draw();
  celsiusButton.update();
  celsiusButton.draw();
  fahrenheitButton.update();
  fahrenheitButton.draw();
}

void displayWeatherData() {
  try {
    String weather = weatherData.getJSONArray("weather").getJSONObject(0).getString("main");
    float temp = weatherData.getJSONObject("main").getFloat("temp") - 273.15;
    if (!isCelsius) {
      temp = temp * 9/5 + 32;
    }
    int humidity = weatherData.getJSONObject("main").getInt("humidity");

    fill(0);
    textSize(32);
    textAlign(CENTER);

    text("City: " + cityInput.getText(), width / 2, 100);
    String tempUnit = isCelsius ? "°C" : "°F";
    text("Temperature: " + nf(temp, 1, 1) + tempUnit, width / 2, 150);
    text("Condition: " + formatWeatherDescription(weather), width / 2, 200);
    text("Humidity: " + humidity + "%", width / 2, 250);

    if (uvData != null) {
      float uvIndex = uvData.getFloat("value");
      text("UV Index: " + formatUVIndex(uvIndex), width / 2, 300);
    }

    PImage weatherIcon = getWeatherIcon(weather);
    if (weatherIcon != null) {
      image(weatherIcon, width / 2 - weatherIcon.width / 2, 350);
    }
  } catch (Exception e) {
    println("Error parsing weather data: " + e.getMessage());
  }
}

PImage getWeatherIcon(String weather) {
  switch (weather) {
    case "Clear":
      return sunImage;
    case "Clouds":
      return cloudImage;
    case "Rain":
      return rainImage;
    case "Thunderstorm":
      return stormImage;
    case "Snow":
      return snowImage;
    default:
      return null;
  }
}

String formatWeatherDescription(String weather) {
  switch (weather) {
    case "Clear":
      return "Clear";
    case "Clouds":
      return "Cloudy";
    case "Rain":
      return "Rainy";
    case "Thunderstorm":
      return "Stormy";
    case "Snow":
      return "Snowy";
    default:
      return weather;
  }
}

String formatUVIndex(float uvIndex) {
  if (uvIndex <= 2) {
    return "Low";
  } else if (uvIndex <= 5) {
    return "Moderate";
  } else if (uvIndex <= 7) {
    return "High";
  } else if (uvIndex <= 10) {
    return "Very High";
  } else {
    return "Extreme";
  }
}

void requestWeatherData(String city) {
  if (city.isEmpty()) {
    println("Please enter a city name.");
    return;
  }

  String weatherUrl = "http://api.openweathermap.org/data/2.5/weather?q=" + city + "&appid=" + apiKey;
  try {
    weatherData = loadJSONObject(weatherUrl);
    float lat = weatherData.getJSONObject("coord").getFloat("lat");
    float lon = weatherData.getJSONObject("coord").getFloat("lon");
    requestUVData(lat, lon);
  } catch (Exception e) {
    println("Error fetching weather data: " + e.getMessage());
  }
}

void requestUVData(float lat, float lon) {
  String uvUrl = "http://api.openweathermap.org/data/2.5/uvi?lat=" + lat + "&lon=" + lon + "&appid=" + apiKey;
  try {
    uvData = loadJSONObject(uvUrl);
  } catch (Exception e) {
    println("Error fetching UV data: " + e.getMessage());
  }
}

void buttonSetup() {
  refreshButton = new Button(50, height - 50, 100, 30, "Refresh");
  refreshButton.setOnClick(() -> {
    requestWeatherData(cityInput.getText());
  });

  celsiusButton = new Button(200, height - 50, 100, 30, "Celsius");
  celsiusButton.setOnClick(() -> {
    if (!isCelsius) {
      isCelsius = true;
      requestWeatherData(cityInput.getText());
    }
  });

  fahrenheitButton = new Button(350, height - 50, 100, 30, "Fahrenheit");
  fahrenheitButton.setOnClick(() -> {
    if (isCelsius) {
      isCelsius = false;
      requestWeatherData(cityInput.getText());
    }
  });
}

void keyPressed() {
  cityInput.keyPressed();
}

void keyTyped() {
  cityInput.keyTyped();

  if (key == ENTER && cityInput.focused) {
    requestWeatherData(cityInput.getText());
  }
}

void mousePressed() {
  refreshButton.mousePressed();
  celsiusButton.mousePressed();
  fahrenheitButton.mousePressed();
  cityInput.mousePressed();
}

void mouseReleased() {
  refreshButton.mouseReleased();
  celsiusButton.mouseReleased();
  fahrenheitButton.mouseReleased();
}

class Button {
  float x, y, w, h;
  String label;
  PFont font;
  boolean over = false;
  boolean pressed = false;
  Runnable onClick;

  Button(float x, float y, float w, float h, String label) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.label = label;
    this.font = createFont("Arial", 16, true);
  }

  void draw() {
    fill(over ? 200 : 255);
    stroke(0);
    rect(x, y, w, h);
    fill(0);
    textFont(font);
    textAlign(CENTER, CENTER);
    text(label, x + w / 2, y + h / 2);
  }

  void update() {
    over = mouseX >= x && mouseX <= x + w && mouseY >= y && mouseY <= y + h;
  }

  void mousePressed() {
    if (over) {
      pressed = true;
    }
  }

  void mouseReleased() {
    if (pressed && over) {
      pressed = false;
      if (onClick != null) {
        onClick.run();
      }
    }
    pressed = false;
  }

  void setOnClick(Runnable onClick) {
    this.onClick = onClick;
  }
}

class TextField {
  float x, y, w, h;
  String text = "";
  String placeholder = "City";
  boolean focused = false;
  boolean cursorVisible = true;
  int cursorTimer = 800;

  TextField(float x, float y, float w, float h) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
  }

  void draw() {
    fill(255);
    stroke(0);
    rect(x, y, w, h);

    fill(0);
    textAlign(LEFT, CENTER);
    if (text.isEmpty() && !focused) {
      fill(150);
      text(placeholder, x + 5, y + h / 2);
    } else {
      fill(0);
      text(text, x + 5, y + h / 2);

      if (focused && millis() % cursorTimer < cursorTimer / 2) {
        float cursorX = x + textWidth(text) + 10;
        line(cursorX, y + 10, cursorX, y + h - 10);
      }
    }
  }

  void mousePressed() {
    focused = mouseX >= x && mouseX <= x + w && mouseY >= y && mouseY <= y + h;
  }

  void keyPressed() {
    if (focused) {
      if (key == BACKSPACE && text.length() > 0) {
        text = text.substring(0, text.length() - 1);
      }
    }
  }

  void keyTyped() {
    if (focused) {
      if (key != BACKSPACE && key != DELETE && key != ENTER) {
        text += key;
      }
    }
  }

  String getText() {
    return text;
  }

  void setText(String newText) {
    text = newText;
  }

  void setFocus(boolean focused) {
    this.focused = focused;
  }

  void setPlaceholder(String placeholder) {
    this.placeholder = placeholder;
  }
}
