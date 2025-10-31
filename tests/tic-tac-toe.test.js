const { Builder, By, until } = require('selenium-webdriver');
const chrome = require('selenium-webdriver/chrome');

(async function detectPlayerTextBug() {
  // URL of the Testing environment (injected by Jenkins)
  const BASE_URL = process.env.BASE_URL || 'http://localhost/';

  // headless chrome
  const options = new chrome.Options();
  options.addArguments('--headless=new');
  options.addArguments('--no-sandbox');
  options.addArguments('--disable-dev-shm-usage');

  let driver = await new Builder()
    .forBrowser('chrome')
    .setChromeOptions(options)
    .build();

  try {
    // 1. Open the app
    await driver.get(BASE_URL);

    // 2. Try to find a cell from common IDs
    const possibleIds = ['cell0', 'cell-0', 'c0', 'cell1', 'cell-1'];
    let cellElement = null;

    for (const id of possibleIds) {
      try {
        cellElement = await driver.wait(
          until.elementLocated(By.id(id)),
          3000
        );
        break;
      } catch (e) {
        // try next
      }
    }

    if (!cellElement) {
      throw new Error('BUG: could not find any game cell (cell0 / cell-0 / c0 / cell1).');
    }

    // 3. Click the cell to trigger the JS
    await cellElement.click();

    // 4. Small wait so the DOM updates
    await driver.sleep(400);

    // 5. Read the text that the app wrote
    const cellText = (await cellElement.getText()).trim();

    // 6. ASSERTION we talked about:
    // If your JS has:  document.getElementById(id).innerHTML = "playerText";
    // then the cell will literally show: playerText
    if (cellText === 'playerText') {
      throw new Error('BUG DETECTED: cell shows literal "playerText" (should use variable playerText without quotes).');
    }

    // Sanity check: it shouldn't be empty either
    if (cellText === '') {
      throw new Error('BUG DETECTED: after click, cell is still empty.');
    }

    console.log('Selenium: cell shows a valid value: ', cellText);
    process.exit(0);
  } catch (err) {
    console.error('Selenium test failed:', err.message);
    // non-zero exit - Jenkins marks stage as failed
    process.exit(1);
  } finally {
    try {
      await driver.quit();
    } catch (e) {
      // ignore
    }
  }
})();
