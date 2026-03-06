---
name: viper-overview
description: Viper FRC/FTC scouting application repository structure, technology stack, and project organization. Use this to understand how the project is organized and find relevant files for requested changes.
---

# Viper Scouting Repository Overview

Viper is an open-source scouting application designed for FRC (FIRST Robotics Competition) and FTC (FIRST Tech Challenge) teams to collect and analyze robot performance data during competitions.

## Project Purpose

- Collects data about robots competing in tournaments
- Helps teams make informed alliance selection decisions
- Provides statistics and analytics for team performance
- Runs as a web app on battery-powered servers at events

## Repository Structure

### `/cgi/` - Perl CGI Backend
**Server-side Perl scripts that handle data processing and API requests**

These scripts support two storage backends:
- **CSV file storage** - Primary and most common option. Supports advanced features like history tracking and rollback. Limited to a single site per installation.
- **MySQL database** - Alternative option that allows multiple sites/hostnames to share the same codebase. Used when you need to host multiple instances with shared infrastructure.

Scripts include:
- `event-list.cgi` - List events
- `event-files.cgi` - Manage event files
- `season-files.cgi` - Manage season files
- `season-scouting.cgi` - Season scouting data
- `user.cgi` - User management
- `revisions.cgi` - Version/revision tracking
- `file.cgi` - File operations
- `offline-service-worker.cgi` - Offline support

Subdirectories:
- `admin/` - Administrative scripts accessible only by admin users. Used for system configuration, data management, and user administration.
- `scout/` - Scout-specific scripts accessible to scouts for uploading new scouting data. These scripts allow data uploads but prevent modification or deletion of existing data, ensuring data integrity.

Scripts in the base `/cgi/` directory allow **read-only access** to data. All write operations are handled by scripts in the subdirectories, providing granular access control based on user role.

### `/www/` - Web Frontend
**HTML, CSS, JavaScript for the user interface**
- Base scouting interfaces: `scout.html`, `pit-scout.html`, `subjective-scout.html`
- Core application logic: `scout.js`, `pit-scout.js`, `subjective-scout.js`
- Season-specific folders with year-specific forms and logic (see "Year-Specific Scouting" workflow)
- `*.cgi` - CGI scripts copied from `/cgi/` for web serving
- `chart.min.js`, `chartjs-boxplot.min.js` - Data visualization libraries
- `*.md` files - User instructions and documentation
- `*.css`, `*.js` - Styling and interactive features

### `/pm/` - Perl Modules
**Reusable Perl utility modules**
- `csv.pm` - CSV file handling
- `db.pm` - Database operations
- `dbimport.pm` - Database import utilities
- `frcapi.pm` - FRC API integration
- `ftcapi.pm` - FTC API integration
- `webutil.pm` - Web utilities

### `/script/` - Installation and Maintenance Scripts
**Bash and Perl scripts for setup and administration**
- `install.sh` - Main installation script (idempotent)
- `software-install.sh` - Install system dependencies
- `db-*.pl` - Database schema, import/export, management
- `apache-config.sh` - Apache web server configuration
- `htaccess-setup.sh`, `cgi-setup.sh` - Web server setup
- `permissions.sh` - File permissions configuration
- `*-enable.sh`, `*-disable.sh` - Feature toggles (DHCP, static IP)
- `git-*.sh` - Git hooks and management
- `*-check.sh` - Code quality checks (tabs, newlines, strict mode)

### `/doc/` - Documentation
**Installation guides and project documentation**
- `linux-install.md` - Linux/Raspberry Pi installation
- `windows-install.md` - Windows XAMPP installation
- `docker-install.md` - Docker development environment
- `hardware.md` - Recommended hardware specifications
- `translation.md` - Internationalization guide

### `/orig/` - Original/Reference Files
**Original system configuration backups (reference only)**

### Root Configuration Files
- `local.conf` - Local configuration (not in git)
- `docker-compose.yml` - Docker Compose setup
- `Dockerfile` - Docker build configuration
- `README.md` - Project overview

## Technology Stack

### Backend
- **Language**: Perl
- **Web Server**: Apache 2 with CGI
- **Storage Options**:
  - **CSV files** (primary) - History tracking, rollback, single site per installation
  - **MySQL database** - Multi-site support with shared codebase
- **API Integration**: FRC/FTC public APIs

### Frontend
- **Languages**: HTML, CSS, JavaScript
- **Key Features**:
  - LocalStorage and indexed db for client-side data persistence
  - SVG and Canvas for field visualization
  - Chart.js for statistics visualization

### DevOps
- Docker & Docker Compose for development
- Git with pre-commit hooks
- Apache .htaccess for URL rewriting
- Shell scripts for automated setup

## Code Quality Standards

The project enforces several code standards via pre-commit hooks:

**Formatting:**
- Tab indentation (not spaces)
- UTF-8 encoding
- Final newlines required
- No trailing whitespace

**Code Requirements:**
- Perl: `use strict` required
- Bash: `set -e` (exit on error) required
- JavaScript: `"use strict"` required at the top of `.js` files; omit end-of-line semicolons when possible; use whitespace sparingly to keep file sizes low
- CSS: Keep selector and properties on a single line when possible to reduce file size
- Remove all `console.log()` statements before committing
- Remove non-exceptional STDERR logging from CGI scripts (keep only genuine exceptions)

## Key Workflows

### Year-Specific Scouting
Each competition season has its own configuration in year-specific directories:
- **FRC seasons** use `/www/YYYY/` format (e.g., `2026/`, `2025/`)
- **FTC seasons** use `/www/YYYY-YY/` format spanning two calendar years (e.g., `2025-26/`, `2024-25/`)

See the "File Location Quick Reference" table under Frontend File Organization for complete file listings for each season.

### Data Management
1. Event data entered via web interface
2. Scouting data collected on tablets/devices offline
3. Data uploaded to server when connectivity available
4. Statistics aggregated and analyzed
5. CSV export for further analysis in Excel/Tableau

### Deployment
1. Run `./script/install.sh` to set up new instance
2. Configure `local.conf` with database credentials
3. Scripts are idempotent - safe to rerun
4. Can be deployed on Raspberry Pi, Windows (XAMPP), or Docker

## Frontend File Organization Conventions

### Page-Specific Files
HTML pages typically have corresponding JavaScript and CSS files with the same base name:
- `page-name.html` - HTML structure
- `page-name.js` - Page-specific JavaScript functionality
- `page-name.css` - Page-specific styles

For example:
- `scout.html`, `scout.js`, `scout.css`
- `event-files.html`, `event-files.js`, `event-files.css`

#### Scout File Hierarchy
The `scout` files have a special hierarchical structure for scouting across multiple seasons:
- **Base files** (`/www/scout.js`, `/www/scout.css`): Used for all FRC and FTC seasons
- **Season-specific HTML** (`/www/YYYY/scout.html` for FRC or `/www/YYYY-YY/scout.html` for FTC): Contains season-specific form structure
- **Season-specific JavaScript/CSS** (`/www/YYYY/scout.js`, `/www/YYYY/scout.css` for FRC or `/www/YYYY-YY/scout.js`, `/www/YYYY-YY/scout.css` for FTC): Supplement the base files with season-specific rules, styles, and scoring logic

This allows shared scouting functionality to be maintained in the base files while each season can customize behavior and appearance as needed.

### Global/Shared Files
- `main.js` - Global JavaScript used across all pages
- `main.css` - Global styles used across all pages
- `event-url.js` - Event/competition-specific utilities used by many pages about specific competitions

This convention helps keep page-specific logic isolated while maintaining shared functionality in global files.

### File Location Quick Reference

| File Type | Location (FRC) | Location (FTC) |
|-----------|---|---|
| Match scouting form | `/www/YYYY/scout.html` | `/www/YYYY-YY/scout.html` |
| Pit scouting form | `/www/YYYY/pit-scout.html` | `/www/YYYY-YY/pit-scout.html` |
| Subjective scouting form | `/www/YYYY/subjective-scout.html` | `/www/YYYY-YY/subjective-scout.html` |
| Scoring/aggregation logic | `/www/YYYY/aggregate-stats.js` | `/www/YYYY-YY/aggregate-stats.js` |
| User instructions | `/www/YYYY/scouting-instructions.md` | `/www/YYYY-YY/scouting-instructions.md` |
| Backend handlers | `/cgi/*.cgi` (source of truth - copied to `/www/` for web serving) |
| Installation scripts | `/script/*.sh` |
| Configuration | `local.conf`, `.env` |
| User documentation | `/doc/*.md` and `/www/*.md` |

**Important Note:** Always modify CGI scripts in the `/cgi/` directory, not in the `/www/` directory. The `/www/` copies are updated by the installation process.

## Third-Party Dependencies

Third-party JavaScript and CSS libraries are managed as **minimized versions** checked into the Git repository:

**License Requirements:**
- All third-party dependencies must be MIT license compatible
- Minimized versions are used to reduce file size and bandwidth

**Current Dependencies:**
Located in `/www/`:
- `chart.min.js` - Chart.js for data visualization
- `chartjs-boxplot.min.js` - Box plot extension for Chart.js
- `canvas-arrow.min.js` - Canvas drawing utilities
- `heatmap.min.js` - Heatmap visualization
- `qrcode.min.js` - QR code generation
- `markdown-it.min.js` - Markdown parser
- `html5sortable.min.js` - Sortable table/list functionality
- `jquery.min.js` - jQuery library
- `tabulator.min.js` - Advanced data table library
- `tabulator.min.css` - Tabulator styling

**Management Process:**
1. Download minimized versions of third-party libraries
2. Place them in the `/www/` directory
3. Commit them to Git
4. Reference them in HTML pages as needed

This approach ensures reproducible builds and eliminates the need for build tools or package managers, keeping the project simple and portable.

## Internationalization (i18n) Translations

The project supports six languages and follows a consistent convention for managing translations:

### Supported Languages
1. **en** - English (default)
2. **fr** - French
3. **pt** - Portuguese
4. **zh_tw** - Traditional Chinese
5. **tr** - Turkish
6. **he** - Hebrew

### Translation Locations

#### Documentation Translations
User-facing markdown documentation has separate files for each language:
- `filename.md` - English version
- `filename.fr.md` - French
- `filename.pt.md` - Portuguese
- `filename.zh_tw.md` - Traditional Chinese
- `filename.tr.md` - Turkish
- `filename.he.md` - Hebrew

Example: `scouting-instructions.md` has corresponding `scouting-instructions.fr.md`, `scouting-instructions.pt.md`, etc.

#### Code String Translations
Strings used in JavaScript code are translated within the code files themselves, following the same naming conventions as CSS/JS files:

**Page-Specific Translations:**
- For strings used only in a specific page, add translations to the page's matching JavaScript file
- Example: Translations used only in `scout.html` go in `scout.js`
- Use the language code as a property key: `en:`, `fr:`, `pt:`, `zh_tw:`, `tr:`, `he:`

**Global/Shared Translations:**
- For strings used across multiple pages, add translations to global JavaScript files like `main.js`
- Or to specialized shared files like `event-url.js` for event/competition-specific strings
- Use the same language code property convention

### Common Translation Task
When adding a new feature with user-visible text:
1. Add the English string to the appropriate `.js` file with all six language translations
2. For documentation, create or update `.md` files for all six languages
3. Follow the existing translation patterns in the codebase

## Related Resources

- Official website: https://viperscout.com/
- GitHub repository: https://github.com/FRCTeam1073-TheForceTeam/viper
- Demo: https://demo.viperscout.com/

## Common Tasks

When helping with Viper:

- **Modifying a scouting form**: Edit the form (e.g., `/www/YYYY/scout.html` for FRC or `/www/YYYY-YY/pit-scout.html` for FTC) and corresponding aggregation logic (e.g., `/www/YYYY/aggregate-stats.js`). Refer to the File Location Quick Reference table for specific file paths.
- **Adding new stat/metric**:
  - If the stat is derived from other existing stats: Update `/www/YYYY/aggregate-stats.js` (FRC) or `/www/YYYY-YY/aggregate-stats.js` (FTC)
  - If new data needs to be collected by scouts:
    1. Add a new input field to one of the scouting forms with appropriate context and presentation:
       - `/www/YYYY/scout.html` or `/www/YYYY-YY/scout.html` - for match scouting data
       - `/www/YYYY/pit-scout.html` or `/www/YYYY-YY/pit-scout.html` - for pit scouting data
       - `/www/YYYY/subjective-scout.html` or `/www/YYYY-YY/subjective-scout.html` - for subjective/qualitative data
    2. Add translations for the field label and description in the corresponding JavaScript file (`scout.js`, `pit-scout.js`, or `subjective-scout.js`)
    3. Define the stat name and category in `/www/YYYY/aggregate-stats.js` (FRC) or `/www/YYYY-YY/aggregate-stats.js` (FTC) for labeling on graphs and reports
    4. Add logic to process and aggregate the collected data in `aggregate-stats.js`
- **Fixing backend issue**: Check `/cgi/` Perl scripts
- **Updating installation**: Modify `/script/install.sh` and related scripts
- **Changing database schema**: The `/script/db-schema.pl` script automatically parses `scouting`, `pit-scouting`, and `subjective-scouting` html files from each season to determine which database columns to create in the corresponding tables. When adding new fields to scouting forms, there is usually no need to modify the script itself—just add the fields to the season-specific form files and the schema will be generated correctly.
- **Adding internationalization**: Follow the patterns for agents documented in the "Internationalization (i18n) Translations" section of this skill
