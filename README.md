# Stock Screener

A Ruby on Rails application for tracking stocks and screening the market based on various financial criteria. This application allows users to manage their stock portfolio and filter stocks using a comprehensive screener interface.

## Features

- **Stock Portfolio Management**: Track stocks with name, quantity, purchase price, and purchase date
- **Stock Screener**: Filter stocks based on:
  - Market Segment (Market Cap)
  - Price and Volume
  - Opinion
  - Fundamentals
  - Earnings and Dividends
  - Debt
- **Real-time Price Data**: Integration with Yahoo Finance API via RapidAPI for current stock prices
- **Modern UI**: Built with Tailwind CSS and Hotwire (Turbo + Stimulus) for a responsive, dynamic experience

## Tech Stack

- **Ruby**: 3.x
- **Rails**: 8.0.2
- **Database**: SQLite3
- **Frontend**: 
  - Tailwind CSS 4.4 for styling
  - Hotwire (Turbo + Stimulus) for dynamic interactions
- **External API**: Yahoo Finance API via RapidAPI

## Prerequisites

- Ruby 3.x
- Rails 8.0.2
- Bundler
- Node.js (for Tailwind CSS compilation)
- SQLite3

## Installation

1. **Clone the repository** (after setting up GitHub):
   ```bash
   git clone https://github.com/YOUR_USERNAME/stock-screener.git
   cd stock-screener
   ```

2. **Install dependencies**:
   ```bash
   bundle install
   ```

3. **Set up the database**:
   ```bash
   rails db:create
   rails db:migrate
   ```

4. **Compile assets**:
   ```bash
   bin/rails tailwindcss:build
   ```

## Configuration

### API Key Setup

The application uses the Yahoo Finance API via RapidAPI. **Important**: Before running the application, you need to configure your API key.

Currently, the API key is stored in `app/services/finance_api_service.rb`. For security, it's recommended to move this to environment variables or Rails credentials.

**Option 1: Using Environment Variables**

1. Create a `.env` file in the root directory (ensure it's in `.gitignore`, which it already is):
   ```bash
   RAPIDAPI_KEY=your_api_key_here
   ```

2. Install the `dotenv-rails` gem and update `FinanceApiService`:
   ```ruby
   @headers = {
     "x-rapidapi-key" => ENV["RAPIDAPI_KEY"],
     "x-rapidapi-host" => "yahoo-finance166.p.rapidapi.com"
   }
   ```

**Option 2: Using Rails Credentials**

1. Edit Rails credentials:
   ```bash
   EDITOR="code --wait" rails credentials:edit
   ```

2. Add:
   ```yaml
   rapidapi:
     key: your_api_key_here
   ```

3. Update `FinanceApiService`:
   ```ruby
   @headers = {
     "x-rapidapi-key" => Rails.application.credentials.rapidapi[:key],
     "x-rapidapi-host" => "yahoo-finance166.p.rapidapi.com"
   }
   ```

## Usage

1. **Start the Rails server**:
   ```bash
   bin/dev
   ```
   Or separately:
   ```bash
   rails server
   ```

2. **Access the application**:
   - Home page: `http://localhost:3000`
   - Stock Screener: `http://localhost:3000/screener`
   - Stocks Management: `http://localhost:3000/stocks`

3. **Manage Stocks**:
   - Navigate to `/stocks` to view all tracked stocks
   - Click "New Stock" to add a new stock entry
   - Edit or delete existing stocks as needed

4. **Use the Screener**:
   - Navigate to `/screener` to access the stock screening interface
   - Use the various filters to screen stocks based on your criteria

## Database Schema

The `stocks` table contains:
- `name` (string): Stock name/symbol
- `quantity` (float): Number of shares
- `purchase_price` (float): Price per share at purchase
- `purchase_date` (string): Date of purchase
- `created_at` (datetime): Record creation timestamp
- `updated_at` (datetime): Record update timestamp

## Testing

Run the test suite:
```bash
rails test
```

Or run specific test files:
```bash
rails test test/models/stock_test.rb
rails test test/controllers/stocks_controller_test.rb
rails test test/system/stocks_test.rb
```

## Development

- **Linting**: Run RuboCop with Rails Omakase configuration:
  ```bash
  bin/rubocop
  ```

- **Security**: Run Brakeman for security analysis:
  ```bash
  bin/brakeman
  ```

- **Asset Compilation**: Watch and compile Tailwind CSS during development:
  ```bash
  bin/rails tailwindcss:watch
  ```

## Project Structure

```
stock-screener/
├── app/
│   ├── controllers/       # Application controllers
│   │   ├── screener_controller.rb
│   │   └── stocks_controller.rb
│   ├── models/           # ActiveRecord models
│   │   └── stock.rb
│   ├── services/         # Service objects
│   │   └── finance_api_service.rb
│   ├── views/            # ERB templates
│   │   ├── home/
│   │   ├── screener/
│   │   └── stocks/
│   └── javascript/       # Stimulus controllers
├── config/               # Configuration files
├── db/                   # Database migrations and schema
└── test/                 # Test files
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is open source and available under the [MIT License](LICENSE).

## Author

Created by [Your Name]

---

**Note**: Remember to configure your RapidAPI key before running the application in production. Never commit API keys to version control.