# 🧠 Neurodivergent-Friendly Budget Tracker

A comprehensive, accessible budget tracking app designed specifically with neurodivergent users in mind. This Flutter application provides customizable themes, sensory accommodations, and cognitive support features to make financial tracking easier and more enjoyable.

## ✨ Features

### 🎨 **Customizable Themes**
- **Low Stim**: Minimal colors, reduced visual noise, no animations
- **High Contrast**: Bold, clear colors for better visibility  
- **Soft Colors**: Gentle, calming pastel palette
- **Standard**: Original colorful theme

### 🚀 **Quick Add Templates**
Pre-filled expense templates for common purchases:
- ☕ Coffee ($5) • 🍽️ Lunch ($12) • 🛒 Groceries ($50)
- 🚌 Bus Fare ($2.50) • ⛽ Gas ($40) • 🅿️ Parking ($5)
- 🎬 Movie ($15) • 📺 Streaming ($10) • 📱 Phone Bill ($50)

### 🧠 **Mood Tracking**
Track your emotional state when spending:
- 😊 Happy • 😰 Stressed • 😟 Anxious • 🤩 Excited
- 😢 Sad • 😐 Neutral • 🤯 Overwhelmed • 😎 Confident

### 🎯 **Visual Progress Indicators**
- Color-coded budget progress bars
- Category-wise spending breakdown
- Clear percentage indicators with traffic light colors
- Motivational budget messages

### 🔔 **Gentle Reminders**
- Smart check-in prompts based on spending patterns
- Time-based reminders (morning, afternoon, evening)
- Streak tracking for consistent logging
- Non-intrusive dismissible notifications

### 🎉 **Achievement System**
Celebrate your progress with achievements for:
- 🎉 First expense logged
- 🏆 Weekly budget goals
- 🌟 Monthly targets
- 🔥 Streak milestones
- 🧠 Mood tracking consistency

### 🧩 **Accessibility Features**
- Clean, low-clutter layout
- Consistent spacing and typography
- Text scaling limits to prevent layout breaks
- High contrast options
- Screen reader friendly
- Haptic feedback support

## 📱 Screenshots

*Coming soon - screenshots of different themes and features*

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.0 or higher)
- Dart SDK (2.17 or higher)
- Android Studio / VS Code
- iOS Simulator / Android Emulator

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/eq_dashboard.git
   cd eq_dashboard
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

## 🏗️ Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── expense.dart         # Expense model with mood tracking
│   ├── habit.dart           # Habit tracking model
│   ├── goal.dart            # Goal management model
│   └── journal_entry.dart   # Journal entry model
├── screens/                 # App screens
│   ├── budget_screen.dart   # Main budget tracking screen
│   ├── dashboard_screen.dart # Overview dashboard
│   ├── habits_screen.dart   # Habit tracking
│   ├── goals_screen.dart    # Goal management
│   └── journal_screen.dart  # Journaling feature
├── utils/                   # Utility classes
│   ├── theme_manager.dart   # Theme system
│   ├── expense_templates.dart # Quick add templates
│   └── feedback_system.dart # Achievement & feedback
└── widgets/                 # Reusable widgets
    └── reminder_widget.dart # Reminder components
```

## 🎨 Themes

### Low Stim Theme
Perfect for users who are sensitive to visual stimulation:
- Neutral gray color palette
- Minimal animations
- Reduced visual noise
- Clean, simple layouts

### High Contrast Theme
Designed for users who need better visibility:
- Bold black and white contrasts
- Clear borders and outlines
- Enhanced text readability
- Strong color differentiation

### Soft Colors Theme
Gentle and calming for sensitive users:
- Pastel color palette
- Rounded corners
- Soft gradients
- Soothing visual experience

## 🧠 Neurodivergent-Friendly Design Principles

This app was built with these key principles:

1. **Reduce Cognitive Load**: Quick templates eliminate decision fatigue
2. **Sensory Accommodation**: Multiple themes for different sensory needs
3. **Emotional Awareness**: Mood tracking helps understand spending triggers
4. **Positive Reinforcement**: Achievement system encourages consistent use
5. **Flexible Interface**: Customizable features that adapt to individual needs
6. **Clear Feedback**: Visual and haptic responses confirm actions
7. **Gentle Reminders**: Non-overwhelming prompts for habit building

## 🤝 Contributing

We welcome contributions that make this app more accessible and useful for neurodivergent users!

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Contribution Guidelines
- Follow Flutter best practices
- Maintain accessibility standards
- Test with different themes
- Consider neurodivergent user needs
- Update documentation

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Built with accessibility and neurodivergent users in mind
- Inspired by inclusive design principles
- Thanks to the Flutter community for accessibility resources

## 📞 Support

If you have questions, suggestions, or need support:
- Open an issue on GitHub
- Check the documentation
- Join our community discussions

---

**Made with ❤️ for the neurodivergent community**
